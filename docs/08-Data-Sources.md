# Data Sources

## ¿Qué es un Data Source?

Un Data Source permite consultar información de recursos que ya existen sin gestionarlos mediante Terraform.

No crea infraestructura.

No modifica infraestructura.

No destruye infraestructura.

Únicamente realiza consultas al proveedor.

---

## Diferencia entre Resource y Data

### Resource

```hcl
resource "aws_s3_bucket" "curso" {
  bucket = var.bucket_name
}
```

Terraform crea y gestiona ese recurso.

---

### Data

```hcl
data "aws_s3_bucket" "curso_existente" {
  bucket = var.bucket_name
}
```

Terraform consulta un recurso existente.

---

## Sintaxis

Los atributos se consultan igual que en un Resource.

Ejemplo:

```hcl
data.aws_s3_bucket.curso_existente.arn
```

```hcl
data.aws_s3_bucket.curso_existente.region
```

```hcl
data.aws_s3_bucket.curso_existente.bucket
```

La única diferencia es el prefijo:

```text
data.
```

---

## Ciclo durante terraform plan

Durante la planificación Terraform realiza:

1. Lectura de los Data Sources.
2. Actualización del State de los Resources.
3. Cálculo de diferencias.
4. Generación del plan.

Por ello es habitual ver mensajes como:

```text
Reading...
Read complete
```

---

## Casos de uso

- Leer una VPC existente.
- Obtener la AMI más reciente.
- Consultar un Bucket creado por otro proyecto.
- Leer un Security Group existente.
- Obtener información de una red corporativa.

---

## Buenas prácticas

Utilizar `resource` cuando Terraform deba crear o gestionar un recurso.

Utilizar `data` cuando únicamente se necesite consultar información existente.

No intentar gestionar mediante `resource` infraestructura creada fuera de Terraform sin realizar antes un `terraform import`.