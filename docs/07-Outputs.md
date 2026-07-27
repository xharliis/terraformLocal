# Outputs

## ¿Qué es un Output?

Un Output es un valor que Terraform devuelve al finalizar la creación o modificación de la infraestructura.

Permite obtener información de los recursos creados sin consultar manualmente el proveedor.

Ejemplo:

```hcl
output "bucket_name" {
  value = aws_s3_bucket.curso.bucket
}
```

---

## Casos de uso

Los Outputs suelen utilizarse para mostrar:

- Nombre de un Bucket.
- ARN de un recurso.
- IP pública de una EC2.
- DNS de un Load Balancer.
- Endpoint de una base de datos.
- ID de una VPC.

---

## Consultar Outputs

Después de ejecutar:

```bash
terraform apply
```

Terraform mostrará automáticamente los Outputs.

También pueden consultarse posteriormente:

```bash
terraform output
```

O un Output concreto:

```bash
terraform output bucket_name
```

---

## ¿Dónde se almacenan?

Los Outputs forman parte del archivo:

```text
terraform.tfstate
```

Por tanto, permanecen disponibles aunque hayan pasado días desde el último `apply`.

---

## Buenas prácticas

Mostrar únicamente información útil para otros módulos, scripts o usuarios.

Ejemplos:

- URL de una aplicación.
- IP pública.
- ARN de un recurso.
- Nombre de un Bucket.

Evitar mostrar información sensible.

---

## Información sensible

Aunque un Output se marque como:

```hcl
sensitive = true
```

su valor continúa almacenándose en el State.

La opción `sensitive` únicamente evita que Terraform lo muestre por pantalla.

Por ello nunca deben exponerse contraseñas, claves privadas o secretos mediante Outputs si pueden evitarse.

## Actualización del State mediante Outputs

Añadir un nuevo Output no modifica la infraestructura.

Sin embargo, Terraform necesita ejecutar `apply` para almacenar ese Output dentro del archivo `terraform.tfstate`.

Por ello puede aparecer un resultado como:

```text
Resources: 0 added, 0 changed, 0 destroyed.
```

Aunque el State sí haya sido actualizado.

---

## Salida en formato JSON

Terraform permite exportar los Outputs en formato JSON:

```bash
terraform output -json
```

Ejemplo:

```json
{
  "bucket_name": {
    "value": "terraform-curso-charlis",
    "type": "string",
    "sensitive": false
  }
}
```

Este formato es el utilizado habitualmente por:

- Scripts Bash
- Python
- GitHub Actions
- Jenkins
- Azure DevOps
- GitLab CI/CD

---

## Obtener un único Output

Puede obtenerse un único valor mediante:

```bash
terraform output bucket_name
```

O en formato plano (sin comillas), muy útil para scripts:

```bash
terraform output -raw bucket_name
```