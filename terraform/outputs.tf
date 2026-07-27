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
