# Laboratorio 09 - State Locking en Terraform con Backend S3

## Objetivo

En este laboratorio aprenderemos cómo Terraform evita que varios usuarios modifiquen el mismo State simultáneamente.

Los objetivos son:

- Entender el problema de concurrencia.
- Ver la diferencia entre backend remoto y backend con locking.
- Configurar el bloqueo del State mediante S3 Lockfile.
- Simular dos usuarios trabajando al mismo tiempo.
- Analizar los errores de bloqueo.

---

# 1. Situación inicial

En laboratorios anteriores configuramos un backend remoto:

```
Terraform

    |
    v

Backend S3

    |
    v

terraform.tfstate
```

Esto solucionaba el problema de compartir el State.

Sin embargo, todavía existía un problema:

¿Qué ocurre si dos personas ejecutan Terraform al mismo tiempo?

---

# 2. Problema sin State Locking

Ejemplo:

```
Usuario A                 Usuario B


terraform apply           terraform apply


       \                    /

              S3

              |

       terraform.tfstate
```

Ambos procesos pueden leer y modificar el State.

Flujo:

```
Estado inicial:

terraform.tfstate

        |
        |

Usuario A lee State

Usuario B lee State

        |
        |

Ambos realizan cambios

        |
        |

Actualizan State
```

Resultado:

- Estados inconsistentes.
- Cambios sobrescritos.
- Posible corrupción del State.

---

# 3. Backend S3 sin locking

Inicialmente teníamos:

```
Terraform

    |

    v

S3

    |

terraform.tfstate
```

El backend remoto permite:

✅ Compartir State.

Pero no evita:

❌ Dos modificaciones simultáneas.

---

# 4. State Locking

Terraform utiliza un bloqueo temporal durante operaciones que modifican el State.

Arquitectura:

```
              Terraform


                  |

                  |


             Backend S3


                  |

        +---------+---------+

        |                   |

 terraform.tfstate     terraform.tfstate.tflock

                         🔒
```

Mientras existe:

```
terraform.tfstate.tflock
```

otro usuario no puede modificar el mismo State.

---

# 5. Configuración del backend

Terraform moderno permite locking nativo mediante S3.

Archivo:

```
backend.tf
```

Configuración:

```hcl
terraform {

  backend "s3" {

    bucket = "terraform-state-lab"

    key = "curso/terraform.tfstate"

    region = "eu-west-1"

    use_lockfile = true


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

# 6. Reinicializar backend

Al cambiar la configuración del backend debemos ejecutar:

```bash
terraform init -reconfigure
```

Terraform vuelve a cargar:

- Backend.
- Providers.
- Configuración de State.

---

# 7. Simular dos usuarios

Utilizamos dos carpetas:

```
Lab08

Lab08-clone
```

Ambas utilizan:

```
terraform-state-lab

        |

        curso/terraform.tfstate
```

---

# 8. Usuario A ejecuta Apply

En la primera terminal:

```bash
terraform apply
```

Terraform crea el bloqueo:

```
terraform.tfstate.tflock
```

Ejemplo:

```
State Lock

ID:
7436d35f

Operation:
Apply

Who:
usuario

Created:
fecha
```

---

# 9. Usuario B intenta aplicar

En la segunda terminal:

```bash
terraform apply
```

Terraform intenta crear otro lock:

```
terraform.tfstate.tflock
```

Pero ya existe.

Resultado:

```
Error acquiring the state lock
```

Ejemplo:

```
Error message:

PreconditionFailed

Lock Info:

ID:
7436d35f

Operation:
OperationTypeApply

Who:
usuario

Version:
1.15.8
```

---

# 10. Liberar un bloqueo manualmente

Normalmente Terraform elimina el bloqueo automáticamente.

Pero si ocurre un fallo:

```
terraform apply

      X

ordenador apagado
```

Puede quedar bloqueado.

Para eliminarlo:

```bash
terraform force-unlock LOCK_ID
```

Ejemplo:

```bash
terraform force-unlock 7436d35f-8fa7-0671-acc8-2bd2f70da9c9
```

⚠️ Solo debe utilizarse cuando estamos seguros de que ningún usuario está ejecutando Terraform.

---

# 11. Método antiguo: DynamoDB

Anteriormente AWS utilizaba:

```
S3

+

DynamoDB
```

Arquitectura:

```
Terraform

     |

     |

S3 Backend

     |

+----+----+

     |

DynamoDB

terraform-locks
```

Configuración antigua:

```hcl
dynamodb_table = "terraform-locks"
```

Actualmente está deprecated en Terraform moderno.

La alternativa recomendada:

```hcl
use_lockfile = true
```

---

# 12. Resultado del laboratorio

Hemos conseguido:

✅ Configurar backend S3 remoto.

✅ Activar State Locking.

✅ Simular dos usuarios.

✅ Ver un error real de bloqueo.

✅ Entender cómo Terraform protege el State.

---

# Conceptos clave aprendidos

Backend remoto:

```
¿Dónde está el State?
```

State Locking:

```
¿Quién puede modificarlo ahora?
```

Terraform profesional:

```
Código Terraform

        +

Backend remoto

        +

State Locking

        +

Infraestructura real
```