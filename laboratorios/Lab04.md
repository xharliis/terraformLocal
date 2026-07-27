# Laboratorio 4 - Precedencia de las Variables

## Objetivo

Comprender cómo decide Terraform qué valor utilizar cuando una misma variable está definida en varios lugares.

Este comportamiento se conoce como **precedencia de variables**.

---

# Situación inicial

Disponemos de la siguiente estructura:

```text
terraform/
│
├── main.tf
├── provider.tf
├── variables.tf
└── terraform.tfvars
```

### variables.tf

```hcl
variable "bucket_name" {
  description = "Nombre del bucket"
  type        = string
}
```

### terraform.tfvars

```hcl
bucket_name = "terraform-curso-charlis"
```

### main.tf

```hcl
resource "aws_s3_bucket" "curso" {
  bucket = var.bucket_name
}
```

---

# Ejercicio 1 - Valor por defecto

Se añade un valor por defecto a la variable.

```hcl
variable "bucket_name" {

  description = "Nombre del bucket"

  type = string

  default = "bucket-por-defecto"

}
```

Posteriormente se ejecuta:

```bash
terraform plan
```

Resultado:

```text
No changes.
```

Terraform continúa utilizando el valor definido en:

```text
terraform.tfvars
```

ignorando el valor por defecto.

---

## Conclusión

El atributo:

```hcl
default
```

no tiene prioridad.

Únicamente actúa como un **valor de respaldo (fallback)** cuando ningún otro valor ha sido proporcionado.

Puede representarse así:

```text
¿Existe un valor definido por el usuario?

        │
     Sí │
        ▼
Utilizar ese valor

        │
     No │
        ▼
Utilizar el default
```

---

# Ejercicio 2 - Archivo de variables personalizado

Se crea un nuevo archivo:

```text
dev.tfvars
```

Con el contenido:

```hcl
bucket_name = "terraform-dev"
```

Se ejecuta:

```bash
terraform plan -var-file="dev.tfvars"
```

Terraform ignora automáticamente el valor de:

```text
terraform.tfvars
```

y utiliza el especificado mediante:

```text
-var-file
```

---

## Resultado

El plan indica:

```text
-/+ destroy and then create replacement
```

Y muestra:

```text
bucket = "terraform-curso-charlis"
↓

bucket = "terraform-dev"

# forces replacement
```

---

## ¿Por qué ocurre?

El nombre de un bucket S3 no puede modificarse una vez creado.

AWS obliga a crear un bucket nuevo.

El Provider de AWS conoce esta limitación y marca ese atributo como:

```text
ForceNew
```

Terraform simplemente aplica esa regla.

---

# Interpretando el Plan

Terraform muestra:

```text
Plan: 1 to add, 0 to change, 1 to destroy.
```

Esto significa:

- destruir el bucket actual
- crear uno nuevo

No significa que existan dos recursos distintos.

Se trata del mismo recurso lógico que necesita ser reemplazado.

---

# Valores "known after apply"

Durante el plan aparecen numerosos valores como:

```text
(known after apply)
```

Ejemplos:

```text
ARN

ID

Hosted Zone

Bucket Domain Name
```

Estos valores no pueden conocerse hasta que AWS crea el recurso.

Terraform los obtendrá durante el:

```text
terraform apply
```

---

# Tipos de cambios que puede realizar Terraform

## Crear

```text
+ create
```

Se crea un recurso nuevo.

---

## Modificar

```text
~ update
```

Se modifica un recurso existente.

Ejemplo:

- añadir una etiqueta
- cambiar una descripción

---

## Eliminar

```text
- destroy
```

Se elimina un recurso existente.

---

## Reemplazar

```text
-/+ replace
```

Terraform destruye el recurso y crea otro nuevo.

Sucede cuando cambia un atributo marcado como:

```text
ForceNew
```

---

# Conceptos aprendidos

- Variables con valor por defecto (`default`).
- El `default` actúa como valor de respaldo.
- Uso de archivos `.tfvars`.
- Uso del parámetro `-var-file`.
- Precedencia entre distintos orígenes de variables.
- Recursos que requieren reemplazo (`ForceNew`).
- Interpretación de `terraform plan`.
- Significado de `(known after apply)`.
- Diferencia entre actualizar un recurso y reemplazarlo.

---

# Resumen

Durante este laboratorio se ha aprendido que:

- Un valor definido en `terraform.tfvars` tiene prioridad sobre el `default`.
- Un archivo indicado mediante `-var-file` tiene prioridad sobre `terraform.tfvars`.
- Terraform no modifica recursos cuya configuración es inmutable; los reemplaza.
- El propio `terraform plan` indica cuándo un atributo obliga al reemplazo mediante el mensaje:

```text
# forces replacement
```

Comprender la precedencia de las variables y saber interpretar un `terraform plan` es fundamental para entender qué acciones realizará Terraform antes de ejecutar un `terraform apply`.