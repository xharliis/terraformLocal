# Terraform Workspaces

## ¿Qué es un Workspace?

Un Workspace es una forma de mantener varios Terraform State independientes utilizando exactamente el mismo código.

El código no cambia.

Lo único que cambia es el State que Terraform utiliza.

---

# ¿Por qué existen?

Permiten desplegar múltiples entornos reutilizando la misma configuración.

Ejemplo:

```
default

↓

empresa-default-logs
```

```
dev

↓

empresa-dev-logs
```

```
prod

↓

empresa-prod-logs
```

Todo ello utilizando el mismo `main.tf`.

---

# Workspace por defecto

Todo proyecto Terraform comienza con un Workspace llamado:

```
default
```

Consultar:

```bash
terraform workspace list
```

---

# Crear un Workspace

```bash
terraform workspace new dev
```

Terraform crea el Workspace y cambia automáticamente a él.

---

# Cambiar de Workspace

```bash
terraform workspace select prod
```

---

# Mostrar Workspace activo

```bash
terraform workspace show
```

---

# Variable especial

Terraform proporciona:

```hcl
terraform.workspace
```

Puede utilizarse para construir nombres automáticamente.

Ejemplo:

```hcl
bucket = "empresa-${terraform.workspace}-logs"
```

Resultado:

Workspace default

```
empresa-default-logs
```

Workspace dev

```
empresa-dev-logs
```

Workspace prod

```
empresa-prod-logs
```

---

# ¿Qué cambia entre Workspaces?

No cambia el código.

No cambia el Provider.

No cambian las Variables.

Únicamente cambia el State.

---

# Organización

```
Mismo código

        │

        ▼

+----------------+

Workspace default

State A

+----------------+

Workspace dev

State B

+----------------+

Workspace prod

State C

+----------------+
```

Cada State administra recursos distintos.

---

# Destroy

Si ejecutamos:

```bash
terraform workspace select prod

terraform destroy
```

Terraform únicamente destruirá los recursos administrados por el State del Workspace `prod`.

Los Workspaces `default` y `dev` permanecerán intactos.

---

# Ventajas

- Reutilización del código.
- Separación de entornos.
- Estados completamente independientes.
- Fácil automatización.
- Muy útil para laboratorios.

---

# Inconvenientes

En organizaciones grandes suele preferirse separar los entornos mediante:

- carpetas distintas;
- repositorios independientes;
- backends diferentes.

Esto permite aplicar permisos, pipelines y revisiones diferentes para producción.

Por ello, los Workspaces suelen utilizarse principalmente para:

- laboratorios;
- pruebas;
- despliegues temporales;
- múltiples instancias similares.

---

# Comandos principales

Crear Workspace

```bash
terraform workspace new dev
```

Cambiar Workspace

```bash
terraform workspace select dev
```

Mostrar Workspace actual

```bash
terraform workspace show
```

Listar Workspaces

```bash
terraform workspace list
```

Eliminar Workspace

```bash
terraform workspace delete dev
```

---

# Ideas clave

- Un Workspace = un Terraform State.
- Todos los Workspaces comparten el mismo código.
- Terraform solo administra los recursos presentes en el State activo.
- `terraform.workspace` permite personalizar automáticamente la infraestructura según el entorno.