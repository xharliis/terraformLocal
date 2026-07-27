# Terraform + LocalStack

Laboratorio personal para usar **Terraform** desde cero utilizando **LocalStack** como entorno local para simular AWS.

---

# Objetivos

- Aprender Infrastructure as Code (IaC).
- Comprender cómo piensa Terraform.
- Gestionar infraestructura de forma declarativa.
- Practicar sin necesidad de una cuenta de AWS gracias a LocalStack.
- Mantener el proyecto versionado con Git.

---

# ¿Qué es Infrastructure as Code (IaC)?

Infrastructure as Code consiste en definir la infraestructura mediante código en lugar de crear recursos manualmente desde una consola.

En lugar de:

- Crear un bucket manualmente.
- Crear una EC2 manualmente.
- Crear una VPC manualmente.

Se describe el estado deseado mediante archivos de configuración.

Ejemplo:

```hcl
resource "aws_s3_bucket" "imagenes" {
  bucket = "empresa-imagenes"
}
```

Terraform será el encargado de crear, modificar o eliminar los recursos necesarios para alcanzar ese estado.

---

# ¿Cómo piensa Terraform?

Terraform es una herramienta **declarativa**.

No se le dice:

```
Haz A.
Después B.
Después C.
```

Se le dice:

```
Quiero llegar a este estado.
```

Terraform calcula automáticamente las acciones necesarias.

---

# Conceptos fundamentales

## Terraform

Herramienta que interpreta los archivos `.tf` y calcula las diferencias entre el estado deseado y el estado real.

---

## Provider

Plugin que permite a Terraform comunicarse con una plataforma concreta.

Ejemplos:

- AWS
- Azure
- Docker
- Kubernetes
- GitHub

Ejemplo:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

---

## Resource

Representa un objeto de infraestructura.

Ejemplos:

- Bucket S3
- EC2
- IAM
- DynamoDB
- VPC

Ejemplo:

```hcl
resource "aws_s3_bucket" "curso" {
  bucket = "terraform-curso-charlis"
}
```

Donde:

- `aws_s3_bucket` → tipo del recurso.
- `curso` → nombre interno para Terraform.
- `terraform-curso-charlis` → nombre real del bucket.

---

# Flujo de trabajo de Terraform

```
Código (.tf)

↓

terraform fmt

↓

terraform validate

↓

terraform plan

↓

terraform apply

↓

Infraestructura creada
```

---

# Comandos importantes

## Inicializar el proyecto

```bash
terraform init
```

Descarga los Providers necesarios.

Equivalente conceptual a:

- npm install
- composer install
- pip install

---

## Formatear código

```bash
terraform fmt
```

Formatea automáticamente los archivos `.tf`.

Se recomienda ejecutarlo antes de cada commit.

---

## Validar sintaxis

```bash
terraform validate
```

Comprueba que la configuración es correcta.

No crea infraestructura.

---

## Ver el plan

```bash
terraform plan
```

No realiza cambios.

Calcula:

- Qué crear.
- Qué modificar.
- Qué eliminar.

Comparando:

- Código
- State
- Infraestructura real

---

## Aplicar cambios

```bash
terraform apply
```

Ejecuta el plan calculado.

---

## Eliminar infraestructura

```bash
terraform destroy
```

Elimina todos los recursos gestionados por Terraform.

---

# Terraform State

Archivo:

```
terraform.tfstate
```

Es la memoria de Terraform.

Contiene la relación entre:

```
Recurso Terraform

↓

Recurso real
```

Ejemplo conceptual:

```
aws_s3_bucket.curso

↓

terraform-curso-charlis
```

Gracias al State Terraform sabe:

- Qué creó.
- Qué controla.
- Qué debe modificar.

---

# Drift

El **Drift** ocurre cuando la infraestructura real deja de coincidir con el estado definido en Terraform.

Ejemplo:

```
Terraform

↓

Bucket debe existir

↓

Usuario borra el bucket manualmente
```

Resultado:

```
terraform plan

↓

+ create
```

Terraform propondrá volver al estado deseado.

---

# Importante

Terraform NO adopta automáticamente recursos existentes.

Si un recurso existe pero no aparece en el State:

```
terraform plan
```

Intentará crearlo nuevamente.

Para incorporarlo al State existe:

```bash
terraform import
```

---

# Diferencia entre Provider y required_providers

## required_providers

Indica a Terraform qué plugin descargar.

Ejemplo:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

---

## provider

Configura el Provider descargado.

Ejemplo:

```hcl
provider "aws" {
  region = "eu-west-1"
}
```

---

# LocalStack

LocalStack permite ejecutar servicios AWS en local utilizando Docker.

Ventajas:

- Sin costes.
- Desarrollo offline.
- Pruebas rápidas.
- Entorno reproducible.

---

# Configuración LocalStack

Para S3 es necesario utilizar:

```hcl
s3_use_path_style = true
```

Porque LocalStack no utiliza Virtual Hosted Style por defecto.

---

# Archivos importantes

```
provider.tf
```

Configuración del Provider.

---

```
main.tf
```

Recursos principales.

---

```
variables.tf
```

Variables del proyecto.

---

```
outputs.tf
```

Valores que Terraform mostrará al finalizar.

---

```
terraform.tfvars
```

Valores concretos para las variables.

---

```
terraform.tfstate
```

Estado de Terraform.

No debe modificarse manualmente.

---

```
.terraform.lock.hcl
```

Bloquea las versiones de los Providers.

Debe subirse al repositorio.

---

# Git

Se recomienda versionar:

- Código `.tf`
- `.terraform.lock.hcl`

No subir:

- `.terraform/`
- `terraform.tfstate`
- `terraform.tfvars` (si contiene información sensible)

---

# Comandos AWS CLI

Ver buckets:

```bash
aws s3 ls --endpoint-url=http://localhost:4566
```

Crear bucket manualmente:

```bash
aws s3 mb s3://mi-bucket --endpoint-url=http://localhost:4566
```

Eliminar bucket:

```bash
aws s3 rb s3://mi-bucket --endpoint-url=http://localhost:4566
```

---

# Conceptos aprendidos

- [x] Infrastructure as Code
- [x] HCL
- [x] Provider
- [x] Resource
- [x] terraform init
- [x] terraform fmt
- [x] terraform validate
- [x] terraform plan
- [x] terraform apply
- [x] terraform destroy
- [x] Terraform State
- [x] Drift
- [x] Variables
- [ ] Outputs
- [ ] Data Sources
- [ ] Modules
- [ ] Workspaces
- [ ] Remote State
- [ ] Backend S3
- [ ] DynamoDB Locking
- [ ] CI/CD con GitHub Actions