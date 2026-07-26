## Laboratorio 2 - Pérdida del State

### Objetivo

Comprobar qué ocurre cuando la infraestructura existe, pero Terraform pierde el archivo `terraform.tfstate`.

### Hipótesis

Terraform no reconstruye automáticamente el State.

### Resultado esperado

Al ejecutar:

```bash
terraform plan
```

Terraform propondrá crear nuevamente el recurso, ya que no tiene ninguna evidencia de haberlo gestionado anteriormente.

### Conclusión

El archivo `terraform.tfstate` no es una caché que pueda regenerarse automáticamente.

Es la fuente de verdad de Terraform sobre qué recursos administra.

Si el State se pierde, es necesario:

- restaurar una copia de seguridad, o
- utilizar `terraform import` para asociar los recursos existentes con Terraform.