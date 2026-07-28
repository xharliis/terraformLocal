#definimos el recurso que queremos crear en AWS

resource "aws_s3_bucket" "curso" { # curso es el identificador para terraform

  #indicamos el nombre del bucket interno para aws o localstack con variables
  bucket = var.bucket_name

}


#usamos modulos ahora
/*
module "curso_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.bucket_name
}


module "bucket" {

  source = "./modules/s3_bucket"

  for_each = var.bucket_names

  bucket_name = each.value
}
*/
