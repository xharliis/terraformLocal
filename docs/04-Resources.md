## Interpretando un `terraform plan`

Terraform utiliza símbolos para indicar qué ocurrirá con cada recurso.

### Crear

```text
+ create
```

Se creará un recurso nuevo.

---

### Actualizar

```text
~ update
```

Se modificará un recurso existente.

---

### Eliminar

```text
- destroy
```

Se eliminará un recurso existente.

---

### Reemplazar

```text
-/+ destroy and then create replacement
```

Terraform destruirá el recurso y creará uno nuevo.

Esto ocurre cuando cambia un atributo marcado por el proveedor como **ForceNew**.

Ejemplo:

```text
bucket = "terraform-curso-charlis"

↓

bucket = "terraform-dev"

# forces replacement
```

---

## Valores conocidos después del Apply

Durante `terraform plan` pueden aparecer valores como:

```text
(known after apply)
```

Significa que Terraform todavía no conoce ese valor porque será generado por el proveedor durante la creación del recurso.

Ejemplos:

- ARN
- ID
- Endpoints
- Direcciones IP públicas
- Hosted Zone ID