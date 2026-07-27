# Laboratorio 07 - Creando múltiples recursos con for_each

## Objetivo

Aprender a crear múltiples recursos reutilizando un único módulo.

---

# Problema

Queremos crear varios buckets.

Sin módulos haríamos algo parecido a:

```hcl
resource "aws_s3_bucket" "logs" {}

resource "aws_s3_bucket" "imagenes" {}

resource "aws_s3_bucket" "backups" {}
```

Esto genera mucho código repetido.

---

# Solución

Crear una colección.

```hcl
variable "bucket_names" {

  type = set(string)

  default = [
    "terraform-curso-charlis",
    "terraform-logs",
    "terraform-backups",
    "terraform-imagenes"
  ]

}
```

Y utilizar:

```hcl
module "bucket" {

  source = "./modules/s3_bucket"

  for_each = var.bucket_names

  bucket_name = each.value

}
```

---

# ¿Qué hace for_each?

Terraform recorrerá la colección.

Para cada elemento:

- crea una instancia del módulo
- pasa el valor correspondiente
- registra una instancia distinta en el State

---

# El State

Terraform ya no tendrá un único módulo.

Ahora tendrá uno por cada bucket.

Ejemplo:

```
module.bucket["terraform-logs"]

module.bucket["terraform-backups"]

module.bucket["terraform-imagenes"]

module.bucket["terraform-curso-charlis"]
```

Cada uno es independiente.

---

# Ventajas

Añadir un bucket nuevo únicamente requiere modificar la colección.

Ejemplo:

```hcl
"default" = [

    "logs",

    "imagenes",

    "backups",

    "copias"

]
```

Terraform detectará:

```
+ Create bucket copias
```

Nada más.

---

Eliminar uno:

```hcl
"default" = [

    "logs",

    "imagenes"

]
```

Terraform propondrá:

```
Destroy backups
```

Los demás permanecerán intactos.

---

# Cambio de orden

Si únicamente cambiamos el orden:

```hcl
imagenes

logs

backups
```

Terraform NO hará cambios.

Porque identifica cada recurso mediante su clave.

No por la posición.

---

# Salidas

Podemos generar mapas completos.

```hcl
output "bucket_names" {

  value = {

    for k, v in module.bucket :

    k => v.bucket_name

  }

}
```

Resultado:

```
terraform output

bucket_names = {

  terraform-logs = ...

  terraform-backups = ...

  terraform-imagenes = ...

}
```

---

# Problema encontrado durante el laboratorio

Al migrar desde un módulo único a un módulo con for_each apareció un problema.

Terraform proponía:

```
Destroy module.curso_bucket

Create module.bucket["terraform-curso-charlis"]
```

La infraestructura era la misma.

El problema era únicamente el State.

---

# Solución

Reasignar el recurso.

En Windows (CMD):

```cmd
terraform import module.bucket[\"terraform-curso-charlis\"].aws_s3_bucket.this terraform-curso-charlis
```

En PowerShell pueden aparecer problemas con las comillas y los índices de `for_each`.

---

# Conceptos aprendidos

for_each crea múltiples instancias independientes.

Cada instancia posee:

- su propio State
- sus propios outputs
- su propio ciclo de vida

---

# Analogía

Tenemos un molde.

```
Módulo Bucket
```

Terraform utiliza ese molde para fabricar tantas copias como elementos existan en la colección.

```
Bucket

↓

Logs

↓

Backups

↓

Imágenes

↓

Curso
```

Todos utilizan el mismo código.

---

# Buenas prácticas

✔ Preferir for_each cuando existe una clave identificadora.

✔ Utilizar set(string) para evitar duplicados.

✔ Evitar copiar y pegar recursos.

✔ Mantener módulos pequeños.

✔ Pensar siempre en la reutilización.

---

# Preguntas de entrevista

## ¿Cuándo utilizarías for_each en lugar de copiar recursos?

Siempre que varios recursos compartan la misma estructura y solo cambien algunos valores.

---

## ¿Qué diferencia hay entre count y for_each?

count utiliza índices:

```
[0]

[1]

[2]
```

for_each utiliza claves:

```
["logs"]

["imagenes"]

["backups"]
```

Por ello, for_each es mucho más estable cuando se añaden o eliminan elementos.

---

## ¿Qué ocurre si cambias el orden de un set?

Nada.

Terraform identifica cada recurso por su clave y no por su posición.

---

## ¿Qué ocurre si cambias una clave?

Terraform interpreta que:

- desaparece un recurso
- aparece otro nuevo

y planificará una destrucción seguida de una creación.

Por ello conviene que las claves sean estables.