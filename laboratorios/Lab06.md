# Laboratorio 06 - Refactorizando a Módulos

## Objetivo

Aprender a reorganizar un proyecto Terraform utilizando módulos sin perder la infraestructura existente.

---

# Situación inicial

Hasta ahora teníamos un bucket definido directamente en el proyecto principal.

```

main.tf

↓

resource "aws_s3_bucket" "curso"

```

Terraform conocía el recurso mediante la dirección:

```

aws_s3_bucket.curso

```

---

# Problema

Queremos reutilizar este código.

Si copiáramos el mismo bloque varias veces terminaríamos con código duplicado.

La solución consiste en crear un módulo.

---

# Estructura creada

```

terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
│
└── modules/
└── s3_bucket/
├── main.tf
├── variables.tf
└── outputs.tf

```

---

# Código del módulo

## variables.tf

```hcl
variable "bucket_name" {
  type = string
}
```

---

## main.tf

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}
```

---

## outputs.tf

```hcl
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
```

---

# Uso del módulo

```hcl
module "curso_bucket" {

  source = "./modules/s3_bucket"

  bucket_name = var.bucket_name

}
```

---

# Problema detectado

Al ejecutar:

```bash
terraform plan
```

Terraform proponía:

```
Destroy aws_s3_bucket.curso

Create module.curso_bucket.aws_s3_bucket.this
```

Aunque era exactamente el mismo bucket.

---

# ¿Por qué ocurre?

Terraform identifica un recurso mediante su dirección dentro del State.

Antes:

```
aws_s3_bucket.curso
```

Ahora:

```
module.curso_bucket.aws_s3_bucket.this
```

Aunque el bucket sea el mismo, Terraform piensa que son recursos distintos.

---

# Solución

Mover el recurso dentro del State.

Existen varias formas.

## Opción 1

terraform state mv

## Opción 2

terraform state rm + terraform import

## Opción 3 (Terraform moderno)

Bloques moved.

---

# Conceptos aprendidos

Un módulo NO crea un recurso distinto.

Simplemente encapsula código.

Terraform únicamente necesita saber dónde está ese recurso dentro del State.

---

# Analogía

Antes:

```
Carpeta principal

↓

Bucket
```

Después:

```
Carpeta principal

↓

Módulo

↓

Bucket
```

El bucket sigue siendo el mismo.

Solo cambia su ubicación lógica.

---

# Buenas prácticas

✔ Crear módulos reutilizables.

✔ Un módulo debe realizar una única tarea.

✔ Variables como entrada.

✔ Outputs como salida.

✔ Evitar duplicar código.

✔ Reutilizar módulos siempre que sea posible.

---

# Preguntas de entrevista

## ¿Qué ventajas tienen los módulos?

- Reutilización.
- Organización.
- Menos código duplicado.
- Mantenimiento más sencillo.

---

## ¿Mover un recurso a un módulo implica recrearlo?

No.

Únicamente cambia su dirección dentro del State.

Si el State se actualiza correctamente no habrá cambios en la infraestructura.

---

## ¿Qué ocurre si no actualizas el State?

Terraform creerá que el recurso antiguo ha desaparecido y propondrá:

- destruir el antiguo
- crear uno nuevo

aunque realmente sea el mismo recurso.