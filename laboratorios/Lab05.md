# Laboratorio 5 - Data Sources

## Objetivo

Aprender a consultar recursos existentes mediante **Data Sources** sin que Terraform los gestione.

---

## Situación inicial

Ya existía un Bucket S3 creado y gestionado por Terraform:

```text
terraform-curso-charlis
```

Queríamos obtener información de ese Bucket utilizando un **Data Source**, simulando el caso en el que el recurso hubiera sido creado por otro proyecto o por otro equipo.

---

## Crear el Data Source

Archivo:

```text
data.tf
```

Contenido:

```hcl
data "aws_s3_bucket" "curso_existente" {
  bucket = var.bucket_name
}
```

Este bloque **no crea ningún recurso**.

Simplemente consulta la infraestructura existente y pone sus atributos a disposición de Terraform.

---

## Utilizar un Data Source

Se añadió un nuevo Output:

```hcl
output "bucket_arn_data" {
  description = "ARN obtenido mediante un Data Source"
  value       = data.aws_s3_bucket.curso_existente.arn
}
```

Obsérvese la diferencia con un Resource:

Resource:

```hcl
aws_s3_bucket.curso.arn
```

Data Source:

```hcl
data.aws_s3_bucket.curso_existente.arn
```

La única diferencia es el prefijo:

```text
data.
```

---

## terraform plan

Resultado:

```text
data.aws_s3_bucket.curso_existente: Reading...
aws_s3_bucket.curso: Refreshing state...
data.aws_s3_bucket.curso_existente: Read complete

Changes to Outputs:
+ bucket_arn_data
```

Terraform realizó tres operaciones:

1. Consultó el Bucket mediante el Data Source.
2. Actualizó la información del recurso gestionado en el State.
3. Detectó que únicamente debía guardar un nuevo Output.

No fue necesario crear ni modificar infraestructura.

---

## ¿Por qué no hay cambios en AWS?

Porque un Data Source únicamente realiza una consulta.

No pertenece a la infraestructura gestionada por Terraform.

No aparece como un Resource.

No puede modificarse.

No puede destruirse.

---

## Diferencia entre Resource y Data

### Resource

```hcl
resource "aws_s3_bucket" "curso" {
    bucket = var.bucket_name
}
```

Terraform crea y administra el recurso.

---

### Data

```hcl
data "aws_s3_bucket" "curso_existente" {
    bucket = var.bucket_name
}
```

Terraform únicamente consulta información.

---

## Casos de uso reales

Los Data Sources son muy habituales cuando la infraestructura ya existe.

Ejemplos:

- Leer una VPC creada por otro equipo.
- Obtener la AMI más reciente de Ubuntu.
- Consultar un Security Group corporativo.
- Obtener el ARN de un Bucket existente.
- Leer una Hosted Zone de Route53.

---

## Aprendizajes

- Un Data Source no crea recursos.
- Un Data Source no modifica recursos.
- Un Data Source no destruye recursos.
- Los Data Sources se leen durante `terraform plan` y `terraform apply`.
- Los atributos obtenidos pueden utilizarse en Resources y Outputs.
- Los Data Sources permiten reutilizar infraestructura existente sin necesidad de realizar un `terraform import`.

---

## Concepto clave

Terraform distingue claramente dos responsabilidades:

```text
Resource
↓

Terraform crea y administra la infraestructura.
```

```text
Data Source
↓

Terraform únicamente consulta información de una infraestructura existente.
```

---

## Analogía

Un Resource sería equivalente a:

```sql
INSERT
UPDATE
DELETE
```

Mientras que un Data Source sería equivalente a:

```sql
SELECT
```

No modifica datos; únicamente los consulta.

---

## Conclusión

Los Data Sources permiten integrar proyectos Terraform con infraestructuras ya existentes.

Es muy común que un proyecto cree únicamente algunos recursos (EC2, Lambdas, Bases de Datos...) mientras reutiliza otros (VPC, Subredes, Security Groups, AMIs...) mediante Data Sources.

En proyectos empresariales, este patrón es uno de los más utilizados.