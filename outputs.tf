output "apis" {
  value = [
    for api in module.http_apis :
    api
  ]
}
