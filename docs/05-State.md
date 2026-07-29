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

# Terraform State Avanzado

## Introducción

El Terraform State es el archivo donde Terraform almacena la relación entre:

- Código Terraform.
- Recursos reales.
- Identificadores de la infraestructura.

Ejemplo:

```
Código Terraform

aws_s3_bucket.logs


        ↓


Terraform State


        ↓


AWS

terraform-logs
```

El State no es la infraestructura.

Es el mapa que permite a Terraform saber qué recursos administra.

---

# terraform state list

## Función

Lista todos los recursos registrados en el State.

Uso:

```bash
terraform state list
```

Ejemplo:

```
aws_s3_bucket.logs

module.storage.aws_s3_bucket.this
```

---

## Importante

No consulta AWS.

Consulta únicamente el State actual.

---

# terraform state show

## Función

Muestra los detalles almacenados de un recurso.

Uso:

```bash
terraform state show RECURSO
```

Ejemplo:

```bash
terraform state show aws_s3_bucket.logs
```

Salida:

```
resource "aws_s3_bucket" "logs" {

 bucket = "empresa-logs"

 arn = "arn:aws:s3:::empresa-logs"

}
```

---

# terraform state mv

## Función

Mueve un recurso dentro del State.

No modifica la infraestructura.

Solo cambia la referencia interna.

---

## Problema habitual

Antes:

```
aws_s3_bucket.logs
```

Después de una refactorización:

```
module.storage.aws_s3_bucket.this
```

Terraform pensaría:

```
Eliminar recurso antiguo

Crear recurso nuevo
```

---

## Solución

Mover el recurso:

```bash
terraform state mv \
aws_s3_bucket.logs \
module.storage.aws_s3_bucket.this
```

Resultado:

Antes:

```
State

aws_s3_bucket.logs
```

Después:

```
State

module.storage.aws_s3_bucket.this
```

La infraestructura permanece igual.

---

# terraform state rm

## Función

Elimina un recurso del State.

No elimina el recurso real.

Ejemplo:

```bash
terraform state rm aws_s3_bucket.logs
```

Resultado:

```
Terraform State

(vacío)


AWS

empresa-logs
```

---

## Casos de uso

- Dejar de gestionar un recurso.
- Migrar recursos entre proyectos.
- Corregir referencias incorrectas.
- Preparar una importación.

---

# terraform import

## Función

Añade un recurso existente al State.

Ejemplo:

AWS:

```
empresa-produccion
```

Terraform:

```
desconocido
```

Ejecutamos:

```bash
terraform import aws_s3_bucket.logs empresa-produccion
```

Resultado:

```
State

aws_s3_bucket.logs

        ↓

empresa-produccion
```

---

# terraform state pull

## Función

Descarga el State actual en formato JSON.

Uso:

```bash
terraform state pull
```

Ejemplo:

```json
{
 "resources": [
   {
    "type": "aws_s3_bucket"
   }
 ]
}
```

---

## Utilidades

- Backup.
- Auditorías.
- Recuperación.
- Análisis manual.

---

# terraform state push

## Función

Sube un State manualmente.

Uso:

```bash
terraform state push backup.tfstate
```

---

## Advertencia

Puede sobrescribir información.

Debe utilizarse solo para:

- Recuperaciones.
- Migraciones.
- Reparaciones.

---

# Migraciones de recursos

Caso típico:

Antes:

```
resource

aws_instance.server
```

Después:

```
module.server.aws_instance.this
```

Sin migración:

```
destroy antiguo

create nuevo
```

Con migración:

```bash
terraform state mv
```

```
State actualizado

mismo recurso
nueva ubicación
```

---

# Importancia del State en producción

En proyectos reales el State debe:

- Estar remoto.
- Tener bloqueo.
- Tener backups.
- Estar protegido.

Ejemplo:

```
S3 Backend

+
DynamoDB Lock
```

o sistemas equivalentes.

---

# Buenas prácticas

## Nunca editar manualmente el State

Evitar:

```
terraform.tfstate
```

editado a mano.

---

## Usar comandos oficiales

Preferir:

```
terraform state mv

terraform state rm

terraform import
```

---

## Antes de modificar State

Realizar backup:

```bash
terraform state pull > backup.tfstate
```

---

# Resumen

| Comando | Función |
|-|-|
| state list | Listar recursos |
| state show | Ver detalles |
| state mv | Mover recursos |
| state rm | Quitar recursos |
| import | Añadir recursos existentes |
| state pull | Descargar State |
| state push | Restaurar State |

---

# Idea clave

Terraform no identifica un recurso por su nombre en AWS.

Lo identifica por su dirección dentro del State.

Por eso mover recursos dentro del código requiere actualizar el State para evitar destrucciones innecesarias.