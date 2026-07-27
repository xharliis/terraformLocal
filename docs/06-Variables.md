# Buenas prácticas con Variables

## No subir secretos al repositorio

Nunca deben almacenarse credenciales, contraseñas o tokens en archivos versionados.

Incorrecto

```hcl
db_password = "MiPassword123"
```

## Utilizar un archivo de ejemplo

Se recomienda incluir un archivo:

```text
terraform.tfvars.example
```

Con valores ficticios:

```hcl
db_password = "tu_contraseña_aquí"
```

Cada desarrollador creará su propio:

```text
terraform.tfvars
```

Que estará incluido en el `.gitignore`.

---

## Variables sensibles

Terraform permite marcar una variable como sensible:

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Esto evita que su valor aparezca en la salida de comandos como `terraform plan` o `terraform apply`.

> **Importante:** `sensitive = true` no cifra el valor. Solo evita que se muestre por pantalla.

---

## Entornos profesionales

En proyectos reales, los secretos suelen obtenerse desde:

- GitHub Secrets
- GitLab CI/CD Variables
- Jenkins Credentials
- AWS Secrets Manager
- HashiCorp Vault
- Variables de entorno (`TF_VAR_*`)

De este modo, las credenciales nunca se almacenan en el código fuente.