#definimos una variales
variable "bucket_name" {

  description = "Nombre del bucket S3"

  type = string

  default = "bucket-por-defecto" #aqui usamos un valor por defecto en caso de no asignarle uno en el .tfvars 

}
