terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.56" # version igual o superior a 6.56 y menor a 7.0
    }
  }
}

# configuracion para aws nube
# provider "aws" {
#
#   region = "eu-west-1"
#
# }

# configuración para LocalStack
provider "aws" {

  region = "eu-west-1"

  access_key        = "test"
  secret_key        = "test"
  s3_use_path_style = true # esta linea es para que terraform use path-style para los buckets en lugar de domain-style

  endpoints {

    s3       = "http://localhost:4566"
    ec2      = "http://localhost:4566"
    iam      = "http://localhost:4566"
    dynamodb = "http://localhost:4566"

  }
  # estas lineas son para que terraform no valide las credenciales y el account_id con aws
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

}
