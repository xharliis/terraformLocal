# vamos a guardar el state en un bucket s3 en local, para eso usamos el proveedor s3
terraform {

  backend "s3" {

    bucket = "terraform-state-lab"

    key = "curso/terraform.tfstate"

    region = "eu-west-1"

    endpoints = {

      s3 = "http://localhost:4566"

    }

    skip_credentials_validation = true

    skip_metadata_api_check = true

    skip_requesting_account_id = true

    skip_region_validation = true

    use_path_style = true

  }

}
