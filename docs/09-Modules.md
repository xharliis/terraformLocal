# 09 - Modules

# ¿Qué es un módulo?

Un módulo es un conjunto de recursos Terraform reutilizables.

Puede entenderse como una función que crea infraestructura.

---

# Analogía con programación

| Programación | Terraform |
|--------------|-----------|
| Función | Módulo |
| Parámetros | Variables |
| Código | Resources |
| Return | Outputs |

---

# Estructura típica

```text
modules/

└── s3_bucket/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

Cada módulo constituye un pequeño proyecto Terraform independiente.

---

# Variables

Representan los datos de entrada del módulo.

Ejemplo:

```hcl
variable "bucket_name" {
  type = string
}
```

---

# Resources

Implementan la infraestructura.

Ejemplo:

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}
```

---

# Outputs

Devuelven información al proyecto que utiliza el módulo.

Ejemplo:

```hcl
output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
```

---

# Utilizar un módulo

```hcl
module "imagenes" {

  source = "./modules/s3_bucket"

  bucket_name = "imagenes"
}
```

---

# Acceder a los Outputs

```hcl
module.imagenes.bucket_name

module.imagenes.bucket_arn
```

---

# Reutilización

El mismo módulo puede utilizarse múltiples veces.

```hcl
module "logs" {}

module "imagenes" {}

module "backups" {}
```

Cada uno crea recursos independientes.

---

# Organización habitual

```text
terraform/

├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
│
└── modules/
    ├── ec2/
    ├── s3/
    ├── rds/
    ├── iam/
    └── lambda/
```

---

# Beneficios

- Reutilización de código.
- Mantenimiento centralizado.
- Menor duplicidad.
- Aplicación de estándares.
- Mayor legibilidad.
- Escalabilidad.

---

# Refactorización

Al mover un Resource a un módulo cambia su dirección dentro del State.

Para evitar recrear recursos se utiliza:

```bash
terraform state mv
```

---

# Buenas prácticas

- Un módulo debe tener una única responsabilidad.
- Variables con nombres claros.
- Outputs únicamente cuando sean útiles.
- No exponer información sensible.
- Documentar el módulo.
- Mantener módulos pequeños y reutilizables.

---

# Resumen

Un módulo puede verse como una función de infraestructura:

```text
Variables

↓

Resources

↓

Outputs
```

El usuario del módulo únicamente necesita conocer:

- qué parámetros recibe;
- qué recursos crea;
- qué información devuelve.

La implementación interna queda encapsulada.