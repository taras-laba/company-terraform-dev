module "data_transportation_api_token_secret" {
  source = "../../modules/secret-manager"

  project_id = var.project_id
  secret_id  = "DataTransportationApi__ApiToken"
}

module "fmcsa_api_webkey_secret" {
  source = "../../modules/secret-manager"

  project_id = var.project_id
  secret_id  = "FmcsaApi__WebKey"
}
