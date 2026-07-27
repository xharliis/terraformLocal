#definimos el recurso que queremos crear en AWS
resource "aws_s3_bucket" "curso" { # curso es el identificador para terraform

  #indicamos el nombre del bucket interno para aws o localstack con variables
  bucket = var.bucket_name

}
