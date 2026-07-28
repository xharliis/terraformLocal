# Laboratorio 08.2 - Compartir Terraform State mediante Backend remoto

## Objetivo

Demostrar cómo varios desarrolladores pueden trabajar sobre la misma infraestructura utilizando un backend remoto.

Aprenderemos:

- Cómo un nuevo usuario recupera el estado.
- Por qué no es necesario compartir `terraform.tfstate`.
- Cómo Terraform utiliza el backend remoto como fuente de verdad.

---

# 1. Situación inicial

Tenemos un proyecto funcionando:

```
Lab08/

├── backend.tf
├── main.tf
├── variables.tf
└── outputs.tf
```

El estado está almacenado en:

```
Backend S3

terraform-state-lab
└── curso
    └── terraform.tfstate
```

---

# 2. Simular un nuevo desarrollador

Creamos una nueva carpeta:

```
Lab08-clone
```

Copiamos:

```
backend.tf
main.tf
variables.tf
outputs.tf
```

No copiamos:

```
terraform.tfstate
```

porque el objetivo es comprobar que Terraform puede trabajar únicamente con el backend remoto.

---

# 3. Inicializar el proyecto

Dentro de la nueva carpeta:

```bash
terraform init
```

Terraform lee:

```
backend.tf
```

y conecta con:

```
terraform-state-lab/curso/terraform.tfstate
```

---

# 4. Consultar el State

Ejecutamos:

```bash
terraform state list
```

Resultado:

```
aws_s3_bucket.curso
```

Aunque en la carpeta no existe:

```
terraform.tfstate
```

Terraform obtiene la información desde S3.

---

# 5. Flujo real de trabajo

En un equipo:

```
                 Backend S3

                    |
                    |
        +-----------+-----------+

        |                       |

     Developer A           Developer B

     Terraform             Terraform
```

Ambos usuarios trabajan sobre el mismo estado.

---

# 6. Cambios desde otro equipo

Supongamos que el estado remoto contiene:

```hcl
bucket = "terraform-curso-charlis-lab"
```

Pero un desarrollador cambia:

```hcl
bucket = "terraform-produccion"
```

Ejecuta:

```bash
terraform plan
```

Terraform compara:

```
Código Terraform

        +

State remoto

        +

Infraestructura real
```

---

# 7. Cambio de nombre de un bucket S3

Terraform detectará:

```
terraform-curso-charlis-lab

        !=

terraform-produccion
```

Pero S3 no permite cambiar el nombre de un bucket existente.

Por tanto el plan será:

```
-/+ destroy and create replacement
```

Significa:

```
- Destruir bucket antiguo

+ Crear bucket nuevo
```

---

# 8. Ventajas del State remoto compartido

## Trabajo colaborativo

Los desarrolladores no necesitan enviarse archivos `.tfstate`.


## Seguridad

El estado no está repartido en ordenadores personales.


## Consistencia

Todos trabajan contra la misma información.


## CI/CD

Los pipelines pueden utilizar el mismo backend.


---

# 9. Concepto clave

Terraform siempre compara:

```
Código Terraform

        +

Terraform State

        +

Infraestructura real
```

El backend solamente cambia dónde se guarda el State.

---

# Resultado del laboratorio

Hemos demostrado:

✅ Un proyecto nuevo puede recuperar la infraestructura existente.

✅ No es necesario tener un `terraform.tfstate` local.

✅ El backend remoto es la fuente de verdad.

✅ Varios usuarios pueden trabajar sobre la misma infraestructura.
