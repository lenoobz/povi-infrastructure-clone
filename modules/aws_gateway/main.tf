/**********************************************************
 * Define local variables
 **********************************************************/

locals {
  prefix              = var.prefix != "" ? "${var.prefix}-" : ""
  domain_name         = "${local.prefix}api.${var.domain_name}"
  gateway_name        = "${local.prefix}${var.gateway_name}"
  authorizer_name     = "${local.prefix}${var.authorizer_name}"
  cloudwatch_log_name = "/aws/api/${local.gateway_name}"
}

data "aws_route53_zone" "zone" {
  name = var.domain_name
}

/**********************************************************
 * Http Api Gateway
 **********************************************************/

resource "aws_apigatewayv2_domain_name" "domain" {
  domain_name = local.domain_name

  domain_name_configuration {
    certificate_arn = var.domain_cert
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = local.gateway_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["*"]
    max_age           = 3600
  }
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = local.authorizer_name

  jwt_configuration {
    audience = [var.cognito_audience]
    issuer   = "https://cognito-idp.${var.cognito_region}.amazonaws.com/${var.cognito_pool_id}"
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log.arn
    format = jsonencode(
      {
        httpMethod         = "$context.httpMethod"
        ip                 = "$context.identity.sourceIp"
        protocol           = "$context.protocol"
        requestId          = "$context.requestId"
        requestTime        = "$context.requestTime"
        responseLength     = "$context.responseLength"
        routeKey           = "$context.routeKey"
        status             = "$context.status"
        integrationMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_api_mapping" "mapping" {
  api_id      = aws_apigatewayv2_api.api.id
  stage       = aws_apigatewayv2_stage.stage.id
  domain_name = local.domain_name
}

/**********************************************************
 * Route53 for api gateway
 **********************************************************/

resource "aws_route53_record" "record" {
  name    = aws_apigatewayv2_domain_name.domain.id
  zone_id = data.aws_route53_zone.zone.zone_id
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

/**********************************************************
 * Log for api gateway
 **********************************************************/

resource "aws_cloudwatch_log_group" "log" {
  name              = local.cloudwatch_log_name
  retention_in_days = var.gateway_log_retention_days
}
