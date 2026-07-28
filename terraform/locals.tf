locals {

  project     = "terraform"
  environment = "dev"

  common_prefix = "${local.project}-${local.environment}"

}
