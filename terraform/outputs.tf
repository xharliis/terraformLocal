
/*
output "bucket_name" {
  description = "Nombre del bucket"
  value       = aws_s3_bucket.curso.bucket
}

output "bucket_arn" {
  description = "ARN del bucket"
  value       = aws_s3_bucket.curso.arn
}

output "bucket_region" {
  description = "Región del bucket"
  value       = aws_s3_bucket.curso.region
}

output "bucket_arn_data" {
  description = "ARN obtenido mediante un Data Source"
  value       = data.aws_s3_bucket.curso_existente.arn
}



#outputs de modulo
output "bucket_name" {
  value = module.curso_bucket.bucket_name
}

output "bucket_arn" {
  value = module.curso_bucket.bucket_arn
}



output "logs_bucket" {
  value = module.logs.bucket_name
}

output "backups_bucket" {
  value = module.backups.bucket_name
}

output "imagenes_bucket" {
  value = module.imagenes.bucket_name
}

*/
#sacamos el nombre de los buckets creados con el for_each
output "bucket_names" {
  value = {
    for nombre, bucket in module.bucket :
    nombre => bucket.bucket_name
  }
}

#sacamos el arn de los buckets creados con el for_each
output "bucket_arns" {
  value = {
    for nombre, bucket in module.bucket :
    nombre => bucket.bucket_arn
  }
}
