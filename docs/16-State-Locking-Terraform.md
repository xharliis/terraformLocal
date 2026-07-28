# State Locking en Terraform

## Introducción

Terraform utiliza un archivo llamado State para conocer la relación entre:

- Código Terraform.
- Recursos creados.
- Infraestructura real.

Ejemplo:

```
Código Terraform

        |

        v

terraform.tfstate

        |

        v

AWS Infrastructure
```

Cuando varios usuarios trabajan sobre la misma infraestructura aparece un problema:

¿Cómo evitamos que dos procesos modifiquen el State al mismo tiempo?

La solución es:

```
State Locking
```

---

# ¿Qué es State Locking?

State Locking es el mecanismo que impide que varios procesos Terraform escriban sobre el mismo State simultáneamente.

Cuando Terraform ejecuta operaciones como:

```bash
terraform apply
```

crea un bloqueo temporal.

---

# Funcionamiento

Sin locking:

```
Usuario A              Usuario B


apply                  apply


   |                     |

   +----------+----------+

              |

             S3

              |

        terraform.tfstate
```

Ambos pueden modificar el estado.

---

Con locking:

```
Usuario A

terraform apply

        |

        v

     LOCK 🔒

        |

terraform.tfstate


Usuario B

terraform apply

        |

        v

Bloqueado
```

---

# ¿Qué operaciones bloquean el State?

Normalmente:

- terraform apply.
- terraform destroy.
- terraform import.
- terraform state mv.
- terraform state rm.

Operaciones de solo lectura normalmente no necesitan modificar el State.

Ejemplo:

```bash
terraform show
```

---

# Backend S3 y Locking

Terraform utiliza el backend S3 para almacenar el State.

Arquitectura:

```
Terraform

     |

     |

Backend S3

     |

+----+----------------+

     |

terraform.tfstate

     |

terraform.tfstate.tflock
```

---

# S3 Lockfile

Las versiones modernas de Terraform utilizan:

```hcl
use_lockfile = true
```

Ejemplo:

```hcl
terraform {

 backend "s3" {

    bucket = "terraform-state"

    key = "prod terraform.tfstate"

    region = "eu-west-1"

    use_lockfile = true

 }

}
```

Cuando Terraform empieza una operación crea:

```
terraform.tfstate.tflock
```

Este archivo representa:

```
State ocupado
```

---

# Información almacenada en el Lock

Cuando existe un bloqueo Terraform guarda información:

Ejemplo:

```
Lock Info:

ID:
7436d35f

Operation:
OperationTypeApply

Who:
usuario

Version:
1.15.8

Created:
fecha
```

Esto permite saber:

- Quién tiene el bloqueo.
- Qué operación está realizando.
- Desde cuándo existe.

---

# Error de State Lock

Cuando otro usuario intenta ejecutar Terraform:

```
terraform apply
```

Terraform detecta:

```
Existe un lock activo
```

Resultado:

```
Error acquiring the state lock
```

Ejemplo:

```
Error:

PreconditionFailed

Lock Info:
 OperationTypeApply
 Who: usuario
```

---

# Recuperación de bloqueos

Normalmente Terraform elimina automáticamente:

```
terraform apply

        |

        v

Cambios aplicados

        |

        v

Eliminar lock
```

Pero si un proceso falla:

```
terraform apply

       X

ordenador apagado
```

puede quedar bloqueado.

Se puede eliminar con:

```bash
terraform force-unlock LOCK_ID
```

---

# DynamoDB Locking

Durante años AWS recomendaba:

```
S3

+

DynamoDB
```

DynamoDB almacenaba la información del bloqueo.

Ejemplo:

```
DynamoDB

terraform-locks

-----------------

LockID

Operation

User

Time
```

Configuración antigua:

```hcl
dynamodb_table = "terraform-locks"
```

---

# Diferencia entre DynamoDB y S3 Lockfile

## DynamoDB

Ventajas:

- Solución histórica.
- Muy extendida.
- Compatible con versiones antiguas.

Desventajas:

- Añade otro servicio.
- Más configuración.

---

## S3 Lockfile

Ventajas:

- Integrado en backend S3.
- Menos componentes.
- Recomendado actualmente.

---

# Importancia en empresas

En un equipo real:

```
Developer A

terraform apply


Developer B

terraform apply
```

Sin locking:

```
❌ Riesgo de corrupción del State
```

Con locking:

```
✅ Un único proceso modifica el State
```

---

# Relación con CI/CD

En pipelines:

```
GitHub Actions

        |

        v

Terraform Apply

        |

        v

Backend S3

        |

        v

State Lock
```

El locking evita que dos pipelines desplieguen simultáneamente.

---

# Resumen

State Locking:

- Protege Terraform State.
- Evita modificaciones simultáneas.
- Es obligatorio en equipos.
- Forma parte de una arquitectura Terraform profesional.

Concepto clave:

> El backend remoto indica dónde vive el State; el locking controla quién puede modificarlo.