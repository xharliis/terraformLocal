# Laboratorio 08 - Backend remoto S3 en Terraform

## Objetivo

En este laboratorio aprenderemos a configurar un backend remoto utilizando S3 para almacenar el Terraform State.

Los objetivos son:

- Entender qué es un backend.
- Diferenciar entre state local y remoto.
- Configurar un backend S3.
- Migrar el almacenamiento del estado.
- Comprobar que Terraform trabaja sin un `terraform.tfstate` local.

---

# 1. ¿Qué es un Backend?

Terraform necesita guardar información sobre la infraestructura que gestiona.

Esa información se almacena en el **Terraform State**.

Por defecto Terraform utiliza un backend local:

```
terraform.tfstate
```

Ejemplo:

```
proyecto/

├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfstate
```

Este sistema funciona correctamente para proyectos pequeños, pero tiene problemas cuando varios desarrolladores trabajan juntos.

Problemas:

- Cada persona tendría su propio state.
- Puede haber diferencias entre estados.
- No existe un punto centralizado.
- Se pueden producir conflictos.

---

# 2. Backend remoto

Un backend remoto cambia dónde Terraform guarda el estado.

Antes:

```
Terraform

    |
    v

terraform.tfstate local
```

Después:

```
Terraform

    |
    v

Backend remoto S3

terraform-state-lab
└── curso
    └── terraform.tfstate
```

El backend remoto se convierte en la fuente de verdad del estado.

---

# 3. Creación del bucket del backend

El bucket donde se almacena el estado debe existir antes de configurar Terraform.

Esto se conoce como infraestructura bootstrap.

Creamos el bucket mediante AWS CLI:

```bash
aws s3 mb s3://terraform-state-lab \
--endpoint-url=http://localhost:4566
```

Comprobamos:

```bash
aws s3 ls \
--endpoint-url=http://localhost:4566
```

Resultado esperado:

```
terraform-state-lab
```

---

# 4. Configuración del backend S3

Creamos el archivo:

```
backend.tf
```

Contenido:

```hcl
terraform {

  backend "s3" {

    bucket = "terraform-state-lab"

    key = "curso/terraform.tfstate"

    region = "eu-west-1"


    endpoints = {

      s3 = "http://localhost:4566"

    }


    skip_credentials_validation = true

    skip_metadata_api_check = true

    skip_requesting_account_id = true

    skip_region_validation = true

    use_path_style = true

  }

}
```

---

# 5. Inicializar Terraform

Cuando se modifica un backend es obligatorio ejecutar:

```bash
terraform init
```

Terraform inicializa:

- Providers.
- Modules.
- Backend.

Ejemplo de salida:

```
Successfully configured the backend "s3"!
```

---

# 6. Primer Apply usando backend remoto

Ejecutamos:

```bash
terraform apply
```

Terraform:

1. Lee la configuración.
2. Consulta el backend remoto.
3. Comprueba que no existe state.
4. Crea los recursos.
5. Guarda el nuevo estado en S3.

---

# 7. Comprobar el State remoto

Ejecutamos:

```bash
aws s3 ls s3://terraform-state-lab/curso/ \
--endpoint-url=http://localhost:4566
```

Resultado:

```
terraform.tfstate
```

Ahora el estado vive en:

```
LocalStack S3

terraform-state-lab
└── curso
    └── terraform.tfstate
```

---

# 8. Diferencia entre backend local y remoto

## Backend local

```
terraform apply

        |
        v

terraform.tfstate
```

El estado está en el ordenador del desarrollador.


---

## Backend remoto

```
terraform apply

        |
        v

Backend S3

        |
        v

terraform.tfstate remoto
```

Todos los usuarios trabajan contra el mismo estado.

---

# 9. Conceptos importantes para entrevistas

## ¿Por qué utilizar un backend remoto?

Porque permite:

- Trabajo colaborativo.
- Estado centralizado.
- Mayor seguridad.
- Integración con CI/CD.
- Recuperación ante pérdida del equipo local.


Respuesta de entrevista:

> Un backend remoto permite almacenar el Terraform State en una ubicación centralizada para que varios usuarios y sistemas puedan trabajar sobre la misma infraestructura evitando estados inconsistentes.


---

## ¿El backend se crea con Terraform?

Normalmente no.

Existe un problema circular:

```
Terraform necesita el backend

pero

el backend necesitaría Terraform para crearse
```

Por eso normalmente se utiliza un proceso bootstrap:

```
Bootstrap

    |
    v

Crea bucket S3 para state


Después:


Terraform

    |
    v

Usa ese backend
```

---

# Resultado del laboratorio

Hemos conseguido:

✅ Configurar un backend S3.

✅ Guardar Terraform State remotamente.

✅ Trabajar sin `terraform.tfstate` local.

✅ Separar infraestructura y almacenamiento del estado.
