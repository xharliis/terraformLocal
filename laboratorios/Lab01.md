## Laboratorio 1 - Detectando Drift

### Objetivo

Comprobar que Terraform detecta cuando la infraestructura real ha sido modificada fuera de Terraform.

### Pasos

1. Crear un bucket mediante Terraform.

```bash
terraform apply
```

2. Eliminar el bucket manualmente.

```bash
aws s3 rb s3://terraform-curso-charlis --endpoint-url=http://localhost:4566
```

3. Ejecutar nuevamente:

```bash
terraform plan
```

### Resultado esperado

Terraform detecta que el recurso ya no existe y propone volver a crearlo.

```
+ create
```

### Conclusión

Terraform no confía únicamente en el archivo `terraform.tfstate`.

Antes de calcular el plan consulta el estado real de la infraestructura para detectar posibles diferencias (drift).

El objetivo final siempre es hacer que la infraestructura real coincida con el estado deseado definido en los archivos `.tf`.