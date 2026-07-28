# Backend S3 en Terraform

## Introducción

Terraform necesita almacenar información sobre la infraestructura que gestiona.

Esta información se guarda en un archivo llamado:

```
terraform.tfstate
```

El State es una pieza fundamental porque Terraform lo utiliza para saber:

- Qué recursos administra.
- Qué valores tienen esos recursos.
- Qué cambios necesita realizar.
- Qué recursos fueron creados por Terraform.

Por defecto Terraform utiliza un backend local, pero en entornos profesionales se suele utilizar un backend remoto.

---

# ¿Qué es un Backend?

Un backend define dónde y cómo Terraform almacena el State.

Por defecto:

```
Terraform
    |
    v
terraform.tfstate local
```

El archivo se guarda dentro del proyecto.

Ejemplo:

```
proyecto/

├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfstate
```

Este enfoque funciona bien para proyectos pequeños, pero tiene limitaciones.

---

# Problemas del backend local

## Trabajo en equipo

Si dos desarrolladores tienen copias diferentes:

```
Developer A

terraform.tfstate
        |
        v
Infraestructura A


Developer B

terraform.tfstate
        |
        v
Infraestructura B
```

Los estados pueden acabar siendo diferentes.

---

## Riesgo de pérdida

Si se pierde el archivo:

```
terraform.tfstate
```

Terraform pierde la referencia de los recursos que administra.

La infraestructura seguirá existiendo, pero Terraform no sabrá qué recursos son suyos.

---

## Falta de control

No existe un punto central donde almacenar el estado.

Esto dificulta:

- Equipos grandes.
- Automatización.
- CI/CD.
- Control de accesos.

---

# Backend remoto

Un backend remoto almacena el State fuera del equipo local.

Ejemplo:

```
Terraform

    |
    v

Backend remoto

    |
    v

terraform.tfstate
```

La ventaja principal es que todos los usuarios trabajan con el mismo estado.

---

# Backend S3

AWS S3 es uno de los backends más utilizados para Terraform.

La arquitectura sería:

```
              Terraform

                  |
                  |

             Backend S3

                  |
                  |

        terraform-state-bucket

                  |
                  |

          terraform.tfstate
```

Terraform no guarda el estado en el proyecto, sino en un bucket S3.

---

# Configuración de un Backend S3

Se configura mediante un bloque:

```hcl
terraform {

  backend "s3" {

    bucket = "terraform-state"

    key = "env/dev/terraform.tfstate"

    region = "eu-west-1"

  }

}
```

---

## Parámetros principales

## bucket

Indica el bucket donde se almacenará el State.

Ejemplo:

```hcl
bucket = "terraform-state"
```

---

## key

Define la ruta dentro del bucket.

Ejemplo:

```hcl
key = "prod/network/terraform.tfstate"
```

Genera:

```
terraform-state

└── prod
    └── network
        └── terraform.tfstate
```

Esto permite almacenar varios estados dentro del mismo bucket.

---

## region

Región donde está almacenado el bucket.

Ejemplo:

```hcl
region = "eu-west-1"
```

---

# Inicialización del Backend

Después de configurar un backend es necesario ejecutar:

```bash
terraform init
```

Terraform:

1. Lee la configuración del backend.
2. Conecta con el almacenamiento remoto.
3. Descarga el State si existe.
4. Inicializa providers y módulos.

---

# Migración de State

Si un proyecto ya tiene un state local:

```
terraform.tfstate
```

y se configura un backend remoto, Terraform puede migrarlo.

Ejemplo:

```bash
terraform init
```

Terraform detectará:

```
Existe state local

Existe backend remoto

¿Quieres migrarlo?
```

Si se acepta:

```
terraform.tfstate local

        |

        v

terraform.tfstate en S3
```

---

# Backend S3 en equipos

Ejemplo de organización:

```
terraform-state-prod

├── dev/
│   └── terraform.tfstate
│
├── staging/
│   └── terraform.tfstate
│
└── prod/
    └── terraform.tfstate
```

Cada entorno tiene su propio estado.

---

# Backend S3 y entornos

Una práctica habitual:

```
Código Terraform

        |

        +------------+
        |            |
        v            v

      DEV          PROD

      State        State

      S3           S3
```

El código puede ser el mismo, cambiando solamente:

- Variables.
- Backend.
- Archivos `.tfvars`.

---

# Seguridad del State

El State puede contener información sensible:

- IDs.
- ARN.
- Datos de recursos.
- Configuraciones.
- Información interna.

Por ello:

- No debe subirse a Git.
- Debe tener permisos controlados.
- Debe protegerse mediante IAM.

---

# Backend S3 en LocalStack

Durante desarrollo local podemos simular AWS mediante LocalStack.

Ejemplo:

```
Terraform

    |

LocalStack

    |

S3 Backend

    |

terraform.tfstate
```

Configuración:

```hcl
terraform {

 backend "s3" {

    bucket = "terraform-state-lab"

    key = "curso/terraform.tfstate"

    region = "eu-west-1"

 }

}
```

---

# Backend remoto vs State local

## Local

```
Equipo desarrollador

terraform.tfstate
```

Ventajas:

- Simple.
- Fácil de comenzar.

Desventajas:

- No colaborativo.
- Riesgo de pérdida.
- Sin control centralizado.

---

## Remoto S3

```
Equipo completo

        |

        v

      S3

        |

        v

terraform.tfstate
```

Ventajas:

- Compartido.
- Centralizado.
- Compatible con CI/CD.
- Mejor control.

---

# Buenas prácticas

## Separar estados

No usar un único State para todo.

Ejemplo:

```
network/
terraform.tfstate


database/
terraform.tfstate


application/
terraform.tfstate
```

---

## Separar entornos

Utilizar diferentes estados:

```
dev
staging
production
```

---

## Proteger el bucket

Aplicar:

- Control IAM.
- Versionado del bucket.
- Cifrado.
- Auditoría.

---

# Limitación del backend S3

S3 por sí solo almacena el State, pero no evita que dos personas hagan cambios simultáneamente.

Ejemplo:

```
Usuario A

terraform apply


Usuario B

terraform apply
```

Ambos podrían intentar modificar el State.

Para solucionar esto se utiliza:

```
S3 Backend

        +

State Locking
```

Actualmente AWS utiliza mecanismos como:

- DynamoDB Locking (modelo tradicional).
- Native S3 Locking en versiones modernas.

---

# Resumen

Un backend S3:

- Almacena remotamente el Terraform State.
- Permite colaboración entre equipos.
- Evita depender de archivos locales.
- Facilita automatización CI/CD.
- Es una práctica estándar en entornos profesionales.

Concepto clave:

> Terraform no administra la infraestructura directamente; administra la relación entre el código, el State y la infraestructura real. El backend define dónde vive esa relación.