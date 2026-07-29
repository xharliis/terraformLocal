# Laboratorio 10 – Terraform Workspaces

## Objetivos

En este laboratorio aprenderás a:

- Crear Workspaces.
- Cambiar entre Workspaces.
- Gestionar varios entornos con el mismo código.
- Entender que cada Workspace posee su propio Terraform State.
- Utilizar `terraform.workspace` para adaptar automáticamente los recursos según el entorno.

---

# Estructura

```
Lab10/

├── backend.tf
├── provider.tf
├── main.tf
└── outputs.tf
```

---

# Backend

Para no reutilizar el State de laboratorios anteriores, utilizamos una nueva clave:

```hcl
terraform {

  backend "s3" {

    bucket = "terraform-state-lab"
    key    = "workspaces/terraform.tfstate"
    region = "eu-west-1"

    use_lockfile = true

    endpoints = {
      s3 = "http://localhost:4566"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
```

---

# Código

```hcl
resource "aws_s3_bucket" "logs" {

  bucket = "empresa-${terraform.workspace}-logs"

}
```

---

# Outputs

```hcl
output "workspace_actual" {

  value = terraform.workspace

}

output "bucket_name" {

  value = aws_s3_bucket.logs.bucket

}
```

---

# Inicializar

```bash
terraform init
```

---

# Ver Workspace actual

```bash
terraform workspace list
```

Salida inicial:

```
* default
```

---

# Plan en default

```bash
terraform plan
```

Terraform propone crear:

```
empresa-default-logs
```

---

# Apply

```bash
terraform apply
```

Se crea:

```
empresa-default-logs
```

---

# Crear Workspace

```bash
terraform workspace new dev
```

Terraform crea el nuevo Workspace y cambia automáticamente a él.

Comprobar:

```bash
terraform workspace list
```

Resultado:

```
default
* dev
```

---

# Plan en dev

Sin modificar el código:

```bash
terraform plan
```

Terraform propone crear:

```
empresa-dev-logs
```

¿Por qué?

Porque el State del Workspace `dev` está vacío.

---

# Apply

```bash
terraform apply
```

Ahora existen dos infraestructuras distintas.

Workspace default

```
empresa-default-logs
```

Workspace dev

```
empresa-dev-logs
```

---

# Cambiar entre Workspaces

Volver al Workspace por defecto.

```bash
terraform workspace select default
```

Terraform carga el State correspondiente.

Al ejecutar:

```bash
terraform plan
```

No hay cambios.

---

# Comprobar Workspace activo

```bash
terraform workspace show
```

Ejemplo:

```
default
```

---

# Conceptos aprendidos

✔ Cada Workspace tiene su propio State.

✔ Todos utilizan exactamente el mismo código.

✔ Terraform solo consulta el State del Workspace activo.

✔ Cambiar de Workspace no cambia el código, únicamente cambia el State.

✔ `terraform.workspace` permite adaptar automáticamente los nombres de recursos.

---

# Buenas prácticas

- Utilizar nombres distintos para recursos compartidos.
- No reutilizar el mismo nombre de bucket entre Workspaces.
- Mantener un backend remoto para todos los Workspaces.
- Utilizar Workspaces para laboratorios, pruebas o entornos similares.

---

# Conclusiones

Los Workspaces permiten reutilizar el mismo código Terraform para desplegar múltiples infraestructuras independientes.

Cada Workspace mantiene un State diferente, por lo que Terraform administra cada entorno de forma completamente aislada.