/**********************************************************
 * Define local variables
 **********************************************************/

locals {
  prefix              = var.prefix != "" ? "${var.prefix}-" : ""
  function_name       = "${local.prefix}${var.function_name}"
  s3_key              = "${local.function_name}.zip"
  role_name           = "${local.function_name}-invoke-role"
  policy_name         = "${local.function_name}-policy"
  cloudwatch_log_name = "/aws/lambda/${local.function_name}"
}

/**********************************************************
 * Lambda function for api
 **********************************************************/

resource "aws_lambda_function" "function" {
  s3_bucket     = var.bucket_name
  s3_key        = local.s3_key
  function_name = local.function_name
  runtime       = var.function_runtime
  handler       = var.function_handler
  timeout       = var.function_timeout_seconds
  role          = aws_iam_role.role.arn
  environment {
    variables = var.function_env_variables
  }
}

/**********************************************************
 * Permission for lambda function
 **********************************************************/

resource "aws_iam_role" "role" {
  name               = local.role_name
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          }
        }
      ]
    }
  EOF
}

resource "aws_iam_role_policy" "policy" {
  name   = local.policy_name
  role   = aws_iam_role.role.name
  policy = <<-EOF
    {
      "Statement": [
        {
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:logs:*:*:*"
        }
      ]
    }
  EOF
}

/**********************************************************
 * Log for lambda function
 **********************************************************/

resource "aws_cloudwatch_log_group" "log" {
  name              = local.cloudwatch_log_name
  retention_in_days = var.api_log_retention_days
}
