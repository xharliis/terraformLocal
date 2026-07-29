# Terraform Lifecycle

## Introducción

El bloque `lifecycle` permite modificar el comportamiento por defecto de Terraform cuando crea, modifica o elimina recursos.

Normalmente Terraform intenta aplicar el cambio más eficiente:

- Crear recursos nuevos.
- Modificar recursos existentes.
- Destruir recursos que ya no existen en la configuración.

Con `lifecycle` podemos controlar cómo debe realizar esos cambios.

---

# Sintaxis básica

```hcl
resource "aws_s3_bucket" "datos" {

  bucket = "empresa-datos"

  lifecycle {

    # reglas del ciclo de vida

  }

}
```

---

# prevent_destroy

## ¿Qué hace?

Impide que Terraform destruya un recurso.

Ejemplo:

```hcl
resource "aws_s3_bucket" "produccion" {

  bucket = "datos-produccion"


  lifecycle {

    prevent_destroy = true

  }

}
```

---

## Comportamiento

Si Terraform detecta que debe eliminar el recurso:

```bash
terraform destroy
```

o:

```bash
terraform plan
```

con un cambio que implique recrearlo.

Terraform bloqueará la operación.

Ejemplo:

```
Error:
Resource cannot be destroyed
```

---

## Uso recomendado

Recursos críticos:

- Bases de datos.
- Buckets con información importante.
- Sistemas de producción.
- Certificados.
- Recursos con datos irreemplazables.

---

# create_before_destroy

## Comportamiento normal

Cuando un recurso necesita reemplazarse Terraform suele hacer:

```
Eliminar recurso antiguo

        ↓

Crear recurso nuevo
```

Esto puede provocar interrupciones.

---

## Con create_before_destroy

Configuración:

```hcl
lifecycle {

  create_before_destroy = true

}
```

Terraform cambia el orden:

```
Crear recurso nuevo

        ↓

Eliminar recurso antiguo
```

---

## Ejemplo

Sin lifecycle:

```
Servidor antiguo

        ↓

Destroy

        ↓

Servidor nuevo
```

Puede existir una caída.

---

Con:

```hcl
create_before_destroy = true
```

```
Servidor nuevo

        ↓

Eliminar servidor antiguo
```

---

## Uso recomendado

Especialmente útil en:

- Instancias.
- Certificados SSL.
- Balanceadores.
- Recursos que requieren alta disponibilidad.

---

# ignore_changes

## ¿Qué hace?

Permite ignorar cambios realizados fuera de Terraform.

Ejemplo:

```hcl
resource "aws_instance" "server" {

  ami = "ami-123"


  lifecycle {

    ignore_changes = [

      tags

    ]

  }

}
```

---

## Sin ignore_changes

Terraform detecta:

```
Código Terraform

tags:
Environment=prod


AWS

tags:
Environment=prod
Owner=Admin
```

Terraform propone:

```
Modificar tags
```

---

## Con ignore_changes

Terraform ignora esa diferencia:

```
No changes.
Infrastructure matches configuration.
```

---

## Uso recomendado

Cuando existen sistemas externos que modifican recursos:

- Sistemas de monitorización.
- Herramientas de seguridad.
- Automatizaciones externas.
- Etiquetado automático.

---

# replace_triggered_by

Disponible en versiones modernas de Terraform.

Permite indicar que un cambio en otro recurso provoque la recreación de uno determinado.

Ejemplo:

```hcl
resource "aws_instance" "server" {

  lifecycle {

    replace_triggered_by = [

      aws_launch_template.app

    ]

  }

}
```

Si cambia:

```
aws_launch_template.app
```

Terraform reemplaza:

```
aws_instance.server
```

---

# Buenas prácticas

## No abusar de lifecycle

Lifecycle modifica el comportamiento natural de Terraform.

Debe utilizarse cuando existe una razón clara.

---

## Recomendaciones

Usar:

```
prevent_destroy
```

en recursos críticos.

Usar:

```
create_before_destroy
```

cuando exista riesgo de caída.

Usar:

```
ignore_changes
```

solo cuando un sistema externo sea responsable del cambio.

---

# Resumen

| Regla | Función |
|-|-|
| prevent_destroy | Bloquea eliminaciones |
| create_before_destroy | Crea antes de eliminar |
| ignore_changes | Ignora modificaciones externas |
| replace_triggered_by | Fuerza recreaciones |

---

# Idea clave

Lifecycle no cambia qué recursos administra Terraform.

Cambia la forma en la que Terraform realiza las operaciones sobre esos recursos.