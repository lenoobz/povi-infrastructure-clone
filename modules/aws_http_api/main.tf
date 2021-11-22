/**********************************************************
 * Lambda function for api
 **********************************************************/

module "lambda_function" {
  source = "../aws_lambda"

  prefix                   = var.prefix
  bucket_name              = var.bucket_name
  function_name            = var.function_name
  function_runtime         = var.function_runtime
  function_handler         = var.function_handler
  function_timeout_seconds = var.function_timeout_seconds
  api_log_retention_days   = var.api_log_retention_days
  function_env_variables   = var.function_env_variables
}

/**********************************************************
 * Api gateway integration
 **********************************************************/

resource "aws_apigatewayv2_integration" "integration" {
  api_id                 = var.gateway_id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
  integration_uri        = module.lambda_function.function_invoke_arn
}

/**********************************************************
 * Api gateway route
 **********************************************************/

locals {
  routes_map = {
    for entry in var.routes :
    entry.route_name => entry
  }
}

resource "aws_apigatewayv2_route" "route" {
  for_each = local.routes_map

  api_id             = var.gateway_id
  route_key          = "${each.value.route_method} /${each.value.route_version}/${each.value.route_path}"
  target             = "integrations/${aws_apigatewayv2_integration.integration.id}"
  authorizer_id      = each.value.attach_authorizer ? var.authorizer_id : null
  authorization_type = each.value.attach_authorizer ? "JWT" : "NONE"
}

/**********************************************************
 * Permission for lambda function
 **********************************************************/

resource "aws_lambda_permission" "permission" {
  for_each = local.routes_map

  statement_id  = "AllowAPIInvoke-${each.value.route_name}"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = module.lambda_function.function_name
  source_arn    = "${var.gateway_arn}/*/*/${each.value.route_version}/${each.value.route_path}"
}
