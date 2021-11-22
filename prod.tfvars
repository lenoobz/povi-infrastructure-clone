prefix                     = "fin"
domain_name                = "lenoob.com"
domain_cert                = "N/A"
gateway_name               = "fund-http-api"
gateway_log_retention_days = 7
lambdas_bucket_name        = "tf-fund-lambdas-storage"

website_bucket_name = "fin.lenoob.com"
website_domain_name = "fin.lenoob.com"

api_list = [
  {
    name                     = "account-management"
    function_name            = "account-management"
    function_runtime         = "nodejs14.x"
    function_handler         = "index.handler"
    function_timeout_seconds = 300
    api_log_retention_days   = 3
    routes = [{
      route_name        = "get-accounts-v1"
      route_method      = "GET"
      route_version     = "v1"
      route_path        = "accounts/{userId}"
      attach_authorizer = false
      }, {
      route_name        = "post-account-v1"
      route_method      = "POST"
      route_version     = "v1"
      route_path        = "account"
      attach_authorizer = false
      }, {
      route_name        = "put-account-v1"
      route_method      = "PUT"
      route_version     = "v1"
      route_path        = "account"
      attach_authorizer = false
      }, {
      route_name        = "delete-account-v1"
      route_method      = "DELETE"
      route_version     = "v1"
      route_path        = "account"
      attach_authorizer = false
      }, {
      route_name        = "get-positions-v1"
      route_method      = "GET"
      route_version     = "v1"
      route_path        = "positions/{userId}"
      attach_authorizer = false
      }, {
      route_name        = "post-position-v1"
      route_method      = "POST"
      route_version     = "v1"
      route_path        = "position"
      attach_authorizer = false
      }, {
      route_name        = "put-position-v1"
      route_method      = "PUT"
      route_version     = "v1"
      route_path        = "position"
      attach_authorizer = false
      }, {
      route_name        = "delete-position-v1"
      route_method      = "DELETE"
      route_version     = "v1"
      route_path        = "position"
      attach_authorizer = false
      }, {
      route_name        = "get-portfolios-v1"
      route_method      = "GET"
      route_version     = "v1"
      route_path        = "portfolios/{userId}"
      attach_authorizer = false
      }, {
      route_name        = "get-breakdowns-v1"
      route_method      = "GET"
      route_version     = "v1"
      route_path        = "breakdowns/{userId}"
      attach_authorizer = false
      }, {
      route_name        = "get-dividends-v1"
      route_method      = "GET"
      route_version     = "v1"
      route_path        = "dividends/{userId}"
      attach_authorizer = false
    }]
  },
  {
    name                     = "assets-management"
    function_name            = "assets-management"
    function_runtime         = "nodejs14.x"
    function_handler         = "index.handler"
    function_timeout_seconds = 300
    api_log_retention_days   = 3
    routes = [{
      route_name        = "get-assets-by-ticker-v1"
      route_method      = "GET"
      route_version     = "v1"
      route_path        = "assets/{ticker}"
      attach_authorizer = false
    }]
  }
]
