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

module "data_protection_keys_secrets" {
  source = "../../modules/secret-manager"

  project_id = var.project_id
  secret_id  = "data-protection-keys"
}