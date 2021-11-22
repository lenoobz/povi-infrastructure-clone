locals {
  prefix       = var.prefix != "" ? "${var.prefix}-" : ""
  machine_name = "${local.prefix}${var.machine_name}"
  role_name    = "${local.machine_name}-invoke-role"
  policy_name  = "${local.machine_name}-policy"
  step_functions = {
    "step_1" = {
      function_name            = "tiprank-dividend-scraper"
      function_runtime         = "go1.x"
      function_handler         = "main"
      function_timeout_seconds = 900
      api_log_retention_days   = 3
    }
    "step_2_a" = {
      function_name            = "tiprank-norm-dividend"
      function_runtime         = "go1.x"
      function_handler         = "main"
      function_timeout_seconds = 120
      api_log_retention_days   = 3
    }
    "step_2_b" = {
      function_name            = "tiprank-norm-list"
      function_runtime         = "go1.x"
      function_handler         = "main"
      function_timeout_seconds = 120
      api_log_retention_days   = 3
    }
  }
}

/**********************************************************
 * List of lambda for state machine
 **********************************************************/

module "scraper_step_functions" {
  for_each = local.step_functions

  source = "../../modules/aws_lambda"

  prefix                   = var.prefix
  bucket_name              = var.bucket_name
  function_name            = each.value.function_name
  function_runtime         = each.value.function_runtime
  function_handler         = each.value.function_handler
  function_timeout_seconds = each.value.function_timeout_seconds
  api_log_retention_days   = each.value.api_log_retention_days
  function_env_variables   = var.function_env_variables
}

locals {
  steps_arn = [for k, step in module.scraper_step_functions : step.function_arn]
}

/**********************************************************
 * State machine
 **********************************************************/

resource "aws_sfn_state_machine" "state_machine" {
  name     = local.machine_name
  role_arn = aws_iam_role.role.arn

  definition = <<EOF
  {
    "Comment": "Invoke AWS Lambda from AWS Step Functions with Terraform",
    "StartAt": "TipRankDividendScraper",
    "States": {
      "TipRankDividendScraper": {
        "Type": "Task",
        "Resource": "${module.scraper_step_functions["step_1"].function_arn}",
        "ResultPath": "$.tickers",
        "Next": "TipRankDividendProcessData"
      },
      "TipRankDividendProcessData": {
        "Type": "Parallel",
        "End": true,
        "Branches": [
          {
            "StartAt": "TipRankNormDividend",
            "States": {
              "TipRankNormDividend": {
                "Type": "Task",
                "Parameters": {
                  "tickers.$": "$.tickers"
                },
                "Resource": "${module.scraper_step_functions["step_2_a"].function_arn}",
                "End": true
              }
            }
          },
          {
            "StartAt": "TipRankNormList",
            "States": {
              "TipRankNormList": {
                "Type": "Task",
                "Parameters": {
                  "tickers.$": "$.tickers"
                },
                "Resource": "${module.scraper_step_functions["step_2_b"].function_arn}",
                "End": true
              }
            }
          }
        ]
      }
    }
  }
  EOF
}

/**********************************************************
 * Permission for state machine
 **********************************************************/

resource "aws_iam_role" "role" {
  name               = local.role_name
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ]
  }
  EOF
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    effect    = "Allow"
    resources = local.steps_arn
  }
}

resource "aws_iam_role_policy" "policy" {
  name = local.policy_name
  role = aws_iam_role.role.id

  policy = data.aws_iam_policy_document.policy.json
}

/**********************************************************
 * Cloudwatch cron job
 **********************************************************/

module "scrape_tiprank_dividend_cron" {
  source = "../../modules/aws_cron_job"

  prefix            = var.prefix
  cron_name         = var.cron_name
  cron_expression   = var.cron_expression
  state_machine_id  = aws_sfn_state_machine.state_machine.id
  state_machine_arn = aws_sfn_state_machine.state_machine.arn
}
