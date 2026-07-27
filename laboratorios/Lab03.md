# Laboratorio 3 - Recuperando el State con `terraform import`

## Objetivo

Aprender a recuperar el archivo `terraform.tfstate` cuando se ha perdido, sin necesidad de recrear la infraestructura existente.

---

## Situación inicial

Disponemos de la siguiente situación:

- El archivo `main.tf` define un bucket S3.
- El bucket existe realmente en AWS/LocalStack.
- El archivo `terraform.tfstate` ha sido eliminado.

Visualmente:

```text
main.tf
    │
    ▼
Bucket definido

terraform.tfstate
    │
    ▼
 No existe

Infraestructura
    │
    ▼
 El bucket existe
```

En este escenario, Terraform no sabe que ese bucket pertenece a su infraestructura.

---

## ¿Qué ocurre si ejecutamos `terraform plan`?

Terraform propondrá crear el bucket de nuevo:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Y si ejecutamos:

```bash
terraform apply
```

Obtendremos un error similar a:

```text
BucketAlreadyOwnedByYou
```

Esto ocurre porque Terraform intenta crear un recurso que ya existe.

---

## Solución

Utilizar el comando:

```bash
terraform import aws_s3_bucket.curso terraform-curso-charlis
```

Donde:

- `aws_s3_bucket.curso` → Dirección del recurso dentro de Terraform.
- `terraform-curso-charlis` → Nombre real del bucket existente.

---

## Resultado del comando

```text
Import successful!

The resources that were imported are shown above.
These resources are now in your Terraform state and will henceforth be managed by Terraform.
```

Terraform ha asociado el recurso existente con el estado interno.

No ha creado ningún recurso nuevo.

No ha modificado la infraestructura.

Únicamente ha reconstruido el `terraform.tfstate`.

---

## Comprobación

Ejecutando de nuevo:

```bash
terraform plan
```

El resultado esperado es:

```text
No changes.

Your infrastructure matches the configuration.
```

Lo que indica que:

- El código (`.tf`).
- El archivo `terraform.tfstate`.
- La infraestructura real.

vuelven a estar completamente sincronizados.

---

# ¿Qué hace realmente `terraform import`?

Internamente Terraform realiza los siguientes pasos:

```text
Localiza el recurso existente

↓

Obtiene toda su configuración

↓

La almacena en terraform.tfstate

↓

A partir de ese momento pasa a gestionarlo
```

Es importante entender que **Terraform no crea el recurso**, simplemente comienza a administrarlo.

---

# ¿Qué NO hace `terraform import`?

Un error muy común es pensar que este comando genera automáticamente el código Terraform.

No es así.

Por ejemplo, este recurso debe existir previamente en `main.tf`:

```hcl
resource "aws_s3_bucket" "curso" {
  bucket = "terraform-curso-charlis"
}
```

`terraform import` únicamente actualiza el archivo `terraform.tfstate`.

---

# Casos de uso reales

`terraform import` es muy utilizado cuando:

- Se pierde el archivo `terraform.tfstate`.
- Se quiere migrar infraestructura creada manualmente a Terraform.
- Una empresa comienza a utilizar Terraform sobre recursos ya existentes.
- Es necesario recuperar el estado tras una incidencia.

---

# Conclusiones

- Terraform no adopta automáticamente recursos existentes.
- El `terraform.tfstate` es la fuente de verdad sobre qué recursos administra Terraform.
- Si el State se pierde, Terraform propondrá crear nuevamente los recursos definidos en el código.
- `terraform import` permite asociar recursos existentes al State sin recrearlos.
- Tras importar un recurso, `terraform plan` debería indicar:

```text
No changes.
```

---

# Conceptos aprendidos

- Recuperación del State.
- Asociación de recursos existentes.
- Funcionamiento de `terraform import`.
- Diferencia entre importar un recurso y crearlo.
- Importancia del `terraform.tfstate`.