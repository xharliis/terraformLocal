## Refresh del State

Durante la ejecución de:

```bash
terraform plan
```

Terraform no se limita a leer el archivo `terraform.tfstate`.

El proceso es:

```text
Leer configuración (.tf)

↓

Leer terraform.tfstate

↓

Consultar la infraestructura real

↓

Refrescar el estado en memoria

↓

Calcular diferencias

↓

Mostrar el plan de ejecución
```

Este proceso se conoce como **Refresh**.

Su objetivo es detectar cambios realizados fuera de Terraform (drift).

> **Importante:** ejecutar `terraform plan` no modifica por sí solo el archivo `terraform.tfstate` en disco. El estado persistente se actualiza cuando se aplican cambios (`terraform apply`) u otras operaciones específicas sobre el estado.

## ¿Por qué Terraform no reconstruye automáticamente el State?

Terraform nunca asume que un recurso existente pertenece a su infraestructura.

Si un recurso existe en AWS pero no aparece en `terraform.tfstate`, Terraform propondrá crearlo de nuevo.

Esto evita que Terraform empiece a gestionar recursos creados por:

- otro proyecto Terraform,
- CloudFormation,
- AWS CDK,
- Pulumi,
- un administrador desde la consola,
- otro equipo.

Para asociar un recurso existente con Terraform debe utilizarse:

```bash
terraform import <direccion_del_recurso> <identificador_real>
```

Ejemplo:

```bash
terraform import aws_s3_bucket.curso terraform-curso-charlis
```

A partir de ese momento Terraform comenzará a gestionar dicho recurso.

# terraform import

## ¿Qué problema resuelve?

Permite asociar un recurso ya existente con Terraform sin tener que volver a crearlo.

Es útil cuando:

- Se pierde el archivo `terraform.tfstate`.
- La infraestructura fue creada manualmente.
- Se migra una infraestructura existente a Terraform.

---

## Sintaxis

```bash
terraform import <direccion_del_recurso> <identificador_real>
```

Ejemplo:

```bash
terraform import aws_s3_bucket.curso terraform-curso-charlis
```

Donde:

- `aws_s3_bucket.curso` → Dirección interna del recurso en Terraform.
- `terraform-curso-charlis` → Identificador real del recurso en AWS.

---

## ¿Qué hace internamente?

Terraform:

1. Localiza el recurso en la infraestructura.
2. Obtiene toda su información.
3. La guarda en `terraform.tfstate`.
4. A partir de ese momento comienza a administrarlo.

No modifica el recurso.

No lo recrea.

Simplemente pasa a formar parte del State.

---

## Resultado esperado

Antes del import:

```text
Plan: 1 to add
```

Después del import:

```text
No changes.
```

---

## Importante

`terraform import` **no genera automáticamente el código Terraform**.

El recurso debe existir previamente en los archivos `.tf`.

El comando únicamente actualiza el `terraform.tfstate`.