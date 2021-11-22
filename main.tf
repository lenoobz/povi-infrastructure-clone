terraform {
  backend "s3" {
    bucket = "tf-fund-state-storage"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

/**********************************************************
 * Cognito
 **********************************************************/

module "povi_cognito" {
  source = "./modules/aws_cognito"

  prefix               = var.prefix
  google_client_id     = var.GOOGLE_CLIENT_ID
  google_client_secret = var.GOOGLE_CLIENT_SECRET
  domain_name          = var.domain_name
  pool_name            = "povi-cognito"
  identity_pool_name   = "povi-google"
  cognito_domain       = "povi-cog"
}

/**********************************************************
 * Fund api gateway
 **********************************************************/

module "api_gateway" {
  source = "./modules/aws_gateway"

  prefix                     = var.prefix
  domain_name                = var.domain_name
  domain_cert                = var.domain_cert
  gateway_name               = var.gateway_name
  gateway_log_retention_days = var.gateway_log_retention_days
  cognito_audience           = module.povi_cognito.app_client_id
  cognito_pool_id            = module.povi_cognito.user_pool_id
  cognito_region             = "us-east-1"
  authorizer_name            = "povi-authorizer"
}

/**********************************************************
 * Http API list
 **********************************************************/

locals {
  apis_map = {
    for entry in var.api_list :
    entry.name => entry
  }
}

module "http_apis" {
  for_each = local.apis_map
  source   = "./modules/aws_http_api"

  prefix                   = var.prefix
  bucket_name              = var.lambdas_bucket_name
  gateway_id               = module.api_gateway.id
  gateway_arn              = module.api_gateway.execution_arn
  authorizer_id            = module.api_gateway.authorizer_id
  function_name            = each.value.function_name
  function_runtime         = each.value.function_runtime
  function_handler         = each.value.function_handler
  function_timeout_seconds = each.value.function_timeout_seconds
  api_log_retention_days   = each.value.api_log_retention_days
  routes                   = each.value.routes
  function_env_variables = {
    MONGO_DB_HOST     = var.MONGO_DB_HOST
    MONGO_DB_USERNAME = var.MONGO_DB_USERNAME
    MONGO_DB_PASSWORD = var.MONGO_DB_PASSWORD
  }

  depends_on = [module.api_gateway]
}

/**********************************************************
 * Vanguard etf scraper machine
 **********************************************************/

module "vanguard_etf_scraper_machine" {
  source = "./scrapers/vanguard_etf"

  prefix          = var.prefix
  bucket_name     = var.lambdas_bucket_name
  machine_name    = "vanguard-ca-etf-scraper-machine"
  cron_name       = "cron-scrape-vanguard-etf"
  cron_expression = "cron(0 12 1 * ? *)"
  function_env_variables = {
    MONGO_DB_HOST     = var.MONGO_DB_HOST
    MONGO_DB_USERNAME = var.MONGO_DB_USERNAME
    MONGO_DB_PASSWORD = var.MONGO_DB_PASSWORD
  }
}

/**********************************************************
 * TipRank dividend scraper machine
 **********************************************************/

module "tiprank_dividend_scraper_machine" {
  source = "./scrapers/tiprank_dividend"

  prefix          = var.prefix
  bucket_name     = var.lambdas_bucket_name
  machine_name    = "tiprank-dividends-scraper-machine"
  cron_name       = "cron-scrape-tiprank-dividend"
  cron_expression = "cron(0 12 ? * MON-FRI *)"
  function_env_variables = {
    MONGO_DB_HOST     = var.MONGO_DB_HOST
    MONGO_DB_USERNAME = var.MONGO_DB_USERNAME
    MONGO_DB_PASSWORD = var.MONGO_DB_PASSWORD
  }
}

/**********************************************************
 * Yahoo price scraper machine
 **********************************************************/

module "yahoo_price_scraper_machine" {
  source = "./scrapers/yahoo_price"

  prefix          = var.prefix
  bucket_name     = var.lambdas_bucket_name
  machine_name    = "yahoo-asset-price-scraper-machine"
  cron_name       = "cron-scrape-yahoo-asset-price"
  cron_expression = "cron(0/30 13-21 ? * MON-FRI *)"
  function_env_variables = {
    MONGO_DB_HOST     = var.MONGO_DB_HOST
    MONGO_DB_USERNAME = var.MONGO_DB_USERNAME
    MONGO_DB_PASSWORD = var.MONGO_DB_PASSWORD
  }
}

/**********************************************************
 * Yahoo asset profile scraper machine
 **********************************************************/

module "yahoo_asset_profile_scraper_machine" {
  source = "./scrapers/yahoo_profile"

  prefix          = var.prefix
  bucket_name     = var.lambdas_bucket_name
  machine_name    = "yahoo-asset-profile-scraper-machine"
  cron_name       = "cron-scrape-yahoo-asset-profile"
  cron_expression = "cron(0 0 * * ? *)"
  function_env_variables = {
    MONGO_DB_HOST     = var.MONGO_DB_HOST
    MONGO_DB_USERNAME = var.MONGO_DB_USERNAME
    MONGO_DB_PASSWORD = var.MONGO_DB_PASSWORD
  }
}

/**********************************************************
 * Povi website
 **********************************************************/

module "povi_ui" {
  source = "./websites/povi_ui"

  prefix        = var.prefix
  domain_name   = var.domain_name
  force_destroy = true
}

/**********************************************************
 * Experiment section : Elastic search service
 **********************************************************/

# resource "aws_elasticsearch_domain" "example" {
#   domain_name           = "dev-elastic"
#   elasticsearch_version = "1.5"

#   cluster_config {
#     instance_type            = "t3.small.elasticsearch"
#     instance_count           = 1
#     dedicated_master_enabled = false
#   }

#   domain_endpoint_options {
#     custom_endpoint_enabled         = true
#     custom_endpoint                 = "dev-elastic.lenoob.com"
#     custom_endpoint_certificate_arn = "N/A"
#   }

#   ebs_options {
#     ebs_enabled = true
#     volume_type = "EBS"
#     volume_size = 10
#   }
# }
