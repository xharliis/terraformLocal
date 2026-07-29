# 15-Locals-y-Funciones.md

# Locals y Funciones en Terraform

## Objetivo

Los `locals` permiten definir valores calculados dentro del proyecto para evitar repetir información y mantener un código más limpio y mantenible.

Las funciones permiten transformar datos (texto, listas, mapas, números...) antes de utilizarlos en recursos, módulos u outputs.

---

# Variables vs Locals

## Variables (`variable`)

Se utilizan para recibir información desde el exterior del proyecto.

Ejemplos:

* Región AWS
* Nombre del proyecto
* Entorno (dev, test, prod)
* Tipo de instancia EC2

```hcl
variable "project" {
  type = string
}

variable "environment" {
  type = string
}
```

Los valores pueden venir desde:

* `terraform.tfvars`
* `*.tfvars`
* `-var`
* Variables de entorno
* Terraform Cloud

---

## Locals (`locals`)

Los `locals` almacenan valores calculados dentro del propio proyecto.

Normalmente se construyen utilizando variables.

```hcl
locals {

  common_prefix = "${var.project}-${var.environment}"

}
```

Posteriormente pueden reutilizarse en cualquier archivo del proyecto.

```hcl
bucket = "${local.common_prefix}-logs"
```

---

# ¿Cuándo usar cada uno?

Usa **variables** cuando el valor pueda cambiar entre ejecuciones.

Ejemplos:

* Región
* Nombre del proyecto
* Entorno
* Tipo de instancia

Usa **locals** cuando el valor sea una transformación o combinación de otros valores.

Ejemplos:

* Prefijos
* Nombres completos
* Etiquetas comunes
* Expresiones reutilizables

---

# Archivo recomendado

```
terraform/
│
├── variables.tf
├── locals.tf
├── outputs.tf
├── main.tf
└── ...
```

No es obligatorio, pero es la estructura utilizada habitualmente en proyectos profesionales.

---

# Ejemplo completo

```hcl
variable "project" {
  default = "empresa"
}

variable "environment" {
  default = "dev"
}
```

```hcl
locals {

  common_prefix = "${var.project}-${var.environment}"

}
```

```hcl
resource "aws_s3_bucket" "logs" {

  bucket = "${local.common_prefix}-logs"

}
```

Resultado:

```
empresa-dev-logs
```

Si únicamente cambia:

```
environment = "prod"
```

Terraform generará automáticamente:

```
empresa-prod-logs
```

---

# Funciones más utilizadas

## lower()

Convierte un texto a minúsculas.

```hcl
lower("Mi Empresa")
```

Resultado:

```
mi empresa
```

---

## upper()

Convierte un texto a mayúsculas.

```hcl
upper("Mi Empresa")
```

Resultado:

```
MI EMPRESA
```

---

## replace()

Reemplaza texto.

```hcl
replace("Mi Empresa", " ", "-")
```

Resultado:

```
Mi-Empresa
```

Muy útil para generar nombres válidos para recursos cloud.

---

## length()

Devuelve la longitud de una cadena o colección.

```hcl
length(var.bucket_names)
```

Resultado:

```
3
```

---

## join()

Une una lista utilizando un separador.

```hcl
join(",", ["logs", "imagenes", "backups"])
```

Resultado:

```
logs,imagenes,backups
```

---

## split()

Hace la operación inversa de `join()`.

```hcl
split(",", "logs,imagenes,backups")
```

Resultado:

```hcl
[
  "logs",
  "imagenes",
  "backups"
]
```

---

## contains()

Comprueba si un elemento existe dentro de una colección.

```hcl
contains(var.bucket_names, "logs")
```

Resultado:

```
true
```

---

## lookup()

Obtiene un valor de un mapa.

```hcl
lookup(var.tags, "Environment", "dev")
```

Si la clave no existe devolverá el valor por defecto.

---

## merge()

Une varios mapas.

```hcl
merge(
  {
    Project = "Curso"
  },
  {
    Environment = "Dev"
  }
)
```

Resultado:

```hcl
{
  Project = "Curso"
  Environment = "Dev"
}
```

Muy utilizada para combinar etiquetas (tags).

---

## keys()

Devuelve las claves de un mapa.

```hcl
keys(var.tags)
```

Resultado:

```hcl
[
  "Project",
  "Environment"
]
```

---

## values()

Devuelve únicamente los valores.

```hcl
values(var.tags)
```

---

## toset()

Convierte una lista en un conjunto (elimina duplicados y no mantiene orden).

Muy utilizada junto con `for_each`.

---

## tolist()

Convierte un conjunto en una lista.

---

# Buenas prácticas

✔ Mantener todos los `locals` en `locals.tf`.

✔ No duplicar variables dentro de `locals` salvo que exista una transformación.

✔ Utilizar `locals` para construir nombres de recursos.

✔ Centralizar prefijos comunes.

✔ Evitar repetir cadenas de texto en múltiples recursos.

---

# Relación con Python

| Python            | Terraform    |
| ----------------- | ------------ |
| `str.lower()`     | `lower()`    |
| `str.upper()`     | `upper()`    |
| `str.replace()`   | `replace()`  |
| `len()`           | `length()`   |
| `",".join(lista)` | `join()`     |
| `split()`         | `split()`    |
| `in`              | `contains()` |
| `dict.get()`      | `lookup()`   |

---

# Preguntas típicas de entrevista

### ¿Cuál es la diferencia entre variables y locals?

Las variables reciben datos desde el exterior del proyecto. Los `locals` calculan y reutilizan valores dentro del propio proyecto.

---

### ¿Por qué utilizar locals?

* Evitan duplicar información.
* Mejoran la legibilidad.
* Facilitan cambios globales.
* Reducen errores de mantenimiento.

---

### ¿Qué funciones son las más utilizadas?

* `lower()`
* `upper()`
* `replace()`
* `length()`
* `join()`
* `split()`
* `contains()`
* `lookup()`
* `merge()`

Estas cubren la mayoría de los casos en proyectos reales.

---

# Resumen

* **Variables** → datos que vienen del exterior.
* **Locals** → valores calculados dentro del proyecto.
* Las funciones permiten transformar esos datos antes de utilizarlos.
* La combinación de `variables + locals + funciones` es una de las bases para escribir configuraciones reutilizables y mantenibles en Terraform.
