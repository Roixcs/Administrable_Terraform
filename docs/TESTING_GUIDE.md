# 🧪 Guía de Pruebas Manuales - Infraestructura Terraform

Esta guía describe cómo probar la infraestructura completa paso a paso, modificando el estado y agregando recursos incrementalmente.

---

## 📋 Pre-requisitos

### Software Requerido
- ✅ Terraform >= 1.9.0
- ✅ Azure CLI
- ✅ Git
- ✅ Bash/PowerShell

### Credenciales de Azure
- Service Principal con permisos de **Contributor**
- O acceso con Azure CLI autenticado

---

## 🚀 Fase 1: Setup Inicial

### Paso 1.1: Clonar el Repositorio

```bash
git clone https://github.com/Roixcs/Administrable_Terraform.git
cd Administrable_Terraform
```

### Paso 1.2: Configurar Credenciales

**Opción A: Variables de Entorno (Recomendado)**

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
```

**Opción B: Editar el tfvars**

```bash
vim terraform/environments/test-dev.tfvars
# Reemplazar los valores de subscription_id, tenant_id, etc.
```

### Paso 1.3: Crear Backend Storage

```bash
cd scripts
chmod +x setup-backend.sh
./setup-backend.sh
```

Esto crea:
- Resource Group: `tfstate-rg`
- Storage Account: `tfstatetestdev`
- Container: `tfstate`

---

## 🧪 Fase 2: Prueba Incremental - Escenario 1

### Objetivo
Desplegar recursos básicos:
- Resource Group
- Storage Account (Static Website)
- Log Analytics

### Paso 2.1: Modificar tfvars

Edita `terraform/environments/test-dev.tfvars`:

```hcl
# Deshabilitar todo excepto lo básico
service_bus = { create = false, namespace_name = "" }
cosmos_db = { create = false, account_name = "", database_name = "" }
key_vault = { create = false, name = "" }
api_management = { create = false, name = "", publisher_name = "", publisher_email = "" }
signalr = { create = false, name = "" }
vnet = { create = false, name = "", address_space = [] }
front_door = { create = false, name = "", sku_name = "Standard_AzureFrontDoor" }
functions_linux = []
functions_windows = []

# Mantener habilitado solo:
resource_group = { create = true, name = "rg-testclient-dev" }
application_insights = { create_workspace = true }
storage_accounts = { ... }  # Mantener
log_analytics = { create = true, ... }  # Mantener
```

### Paso 2.2: Inicializar Terraform

```bash
cd terraform

terraform init \
  -backend-config=backends/test-dev.tfbackend \
  -reconfigure
```

### Paso 2.3: Validar Configuración

```bash
terraform validate
terraform fmt -recursive
```

### Paso 2.4: Plan

```bash
terraform plan \
  -var-file=environments/test-dev.tfvars \
  -out=plan.tfplan
```

**Verificar:**
- ✅ 0 to destroy
- ✅ 4-5 recursos a crear (RG, Storage, Log Analytics, Workspace)

### Paso 2.5: Aplicar

```bash
terraform apply plan.tfplan
```

### Paso 2.6: Verificar Estado

```bash
# Ver recursos creados
terraform state list

# Ver outputs
terraform output
```

---

## 🧪 Fase 3: Prueba Incremental - Escenario 2

### Objetivo
Agregar Service Bus y Cosmos DB sin destruir lo existente

### Paso 3.1: Modificar tfvars

```hcl
# Habilitar Service Bus y Cosmos DB
service_bus = {
  create = true
  namespace_name = "sb-testclient-dev"
  # ... resto de la configuración
}

cosmos_db = {
  create = true
  account_name = "cosmos-testclient-dev"
  # ... resto de la configuración
}
```

### Paso 3.2: Plan de Cambios

```bash
terraform plan \
  -var-file=environments/test-dev.tfvars \
  -out=plan2.tfplan
```

**Verificar:**
- ✅ 0 to destroy ← CRÍTICO
- ✅ X to add (nuevos recursos)
- ✅ 0 to change

### Paso 3.3: Aplicar Cambios

```bash
terraform apply plan2.tfplan
```

### Paso 3.4: Verificar Estado

```bash
terraform state list

# Debe mostrar:
# - Los recursos anteriores (RG, Storage, etc.)
# - Los nuevos recursos (Service Bus, Cosmos DB)
```

---

## 🧪 Fase 4: Prueba Incremental - Escenario 3

### Objetivo
Agregar Functions Linux

### Paso 4.1: Modificar tfvars

```hcl
functions_linux = [
  {
    name    = "fn-testclient-api-dev"
    runtime = "dotnet-isolated"
    version = "8.0"
    app_settings = [...]
  }
]
```

### Paso 4.2: Plan y Aplicar

```bash
terraform plan -var-file=environments/test-dev.tfvars -out=plan3.tfplan
terraform apply plan3.tfplan
```

**Verificar:**
- ✅ 0 to destroy
- ✅ Recursos nuevos: Function App, Storage, App Insights

---

## 🧪 Fase 5: Prueba Incremental - Escenario 4

### Objetivo
Agregar Front Door conectado al Storage Static Website

### Paso 5.1: Modificar tfvars

```hcl
front_door = {
  create = true
  name = "fd-testclient-dev"
  # ... configuración completa
}
```

### Paso 5.2: Subir HTML de Prueba al Storage

```bash
# Crear archivo index.html
echo '<h1>Hello from Azure Front Door!</h1>' > index.html

# Subir al Storage
az storage blob upload \
  --account-name sttestclientdevweb \
  --container-name '$web' \
  --name index.html \
  --file index.html \
  --auth-mode login
```

### Paso 5.3: Aplicar Front Door

```bash
terraform plan -var-file=environments/test-dev.tfvars -out=plan4.tfplan
terraform apply plan4.tfplan
```

### Paso 5.4: Verificar Front Door

```bash
# Obtener endpoint del Front Door
terraform output front_door_endpoint_hostnames

# Probar en navegador o con curl
curl https://<front-door-endpoint>.azurefd.net
```

**Verificar:**
- ✅ Rewrite a index.html funciona
- ✅ Headers de seguridad presentes

```bash
curl -I https://<front-door-endpoint>.azurefd.net

# Debe mostrar:
# X-Content-Type-Options: nosniff
# Strict-Transport-Security: max-age=31536000
# Content-Security-Policy: ...
```

---

## 🧪 Fase 6: Modificación de Recursos Existentes

### Objetivo
Modificar app_settings de una Function sin destruirla

### Paso 6.1: Modificar tfvars

```hcl
functions_linux = [
  {
    name    = "fn-testclient-api-dev"
    app_settings = [
      # Agregar nuevo setting
      {
        name  = "NEW_SETTING"
        value = "test-value"
      }
    ]
  }
]
```

### Paso 6.2: Plan y Aplicar

```bash
terraform plan -var-file=environments/test-dev.tfvars

# Debe mostrar:
# - 0 to destroy
# - 0 to add
# - 1 to change (update in-place)
```

---

## 🧪 Fase 7: Destrucción Controlada

### Objetivo
Eliminar un recurso específico sin afectar los demás

### Paso 7.1: Deshabilitar Front Door

```hcl
front_door = {
  create = false  # ← Cambiar a false
  name = "fd-testclient-dev"
}
```

### Paso 7.2: Plan y Aplicar

```bash
terraform plan -var-file=environments/test-dev.tfvars

# Debe mostrar:
# - X to destroy (solo recursos del Front Door)
# - 0 to add
# - 0 to change en otros recursos
```

---

## 🧪 Fase 8: Destrucción Total

### Solo cuando termines todas las pruebas

```bash
terraform destroy -var-file=environments/test-dev.tfvars
```

---

## 📊 Checklist de Validación

Después de cada fase, verifica:

- [ ] ✅ Estado guardado correctamente en Azure Storage
- [ ] ✅ Plan muestra "0 to destroy" cuando no corresponde
- [ ] ✅ Recursos creados aparecen en Azure Portal
- [ ] ✅ Outputs de Terraform son correctos
- [ ] ✅ Logs de Terraform no muestran errores

---

## 🐛 Troubleshooting

### Error: "Backend not initialized"

```bash
terraform init -backend-config=backends/test-dev.tfbackend -reconfigure
```

### Error: "Storage Account name already exists"

Cambiar el nombre en `test-dev.tfvars` y `test-dev.tfbackend`

### Error: "Insufficient permissions"

Verificar que el Service Principal tenga rol de **Contributor**

### Plan muestra "X to destroy" inesperadamente

1. Revisar el tfvars - quizás cambiaste un nombre
2. Revisar el estado: `terraform state list`
3. NO aplicar hasta entender por qué

---

## 📝 Notas Importantes

1. **SIEMPRE** hacer `terraform plan` antes de `apply`
2. **NUNCA** cambiar nombres de recursos existentes (los destruye)
3. **SIEMPRE** verificar que el plan muestre "0 to destroy"
4. **GUARDAR** backups del state antes de cambios grandes:
   ```bash
   terraform state pull > backup-$(date +%Y%m%d).tfstate
   ```

---

## 🎯 Escenarios de Prueba Sugeridos

1. ✅ Deploy inicial mínimo
2. ✅ Agregar Service Bus + Cosmos DB
3. ✅ Agregar Functions Linux
4. ✅ Agregar Front Door
5. ✅ Modificar app_settings de Function
6. ✅ Agregar nueva Function al array
7. ✅ Agregar Queue al Service Bus
8. ✅ Agregar Container a Cosmos DB
9. ✅ Deshabilitar un recurso (create = false)
10. ✅ Destrucción total

---

## ✅ Criterios de Éxito

La infraestructura es exitosa si:

- ✅ Se pueden agregar recursos sin destruir existentes
- ✅ El estado se guarda correctamente en Azure
- ✅ Los planes muestran "0 to destroy" cuando corresponde
- ✅ Los recursos funcionan correctamente en Azure
- ✅ Se pueden modificar configuraciones sin destruir recursos

---

¡Listo para empezar las pruebas! 🚀
