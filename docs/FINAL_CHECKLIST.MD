# ✅ Checklist Final - Preparación para Pruebas

## 📋 Pre-Validación

### Archivos Creados
- [ ] `terraform/backends/test-dev.tfbackend`
- [ ] `terraform/environments/test-dev.tfvars`
- [ ] `scripts/validate.sh`
- [ ] `docs/TESTING_GUIDE.md`

### Credenciales Configuradas
- [ ] `subscription_id` en tfvars o variables de entorno
- [ ] `tenant_id` en tfvars o variables de entorno
- [ ] `client_id` en tfvars o variables de entorno
- [ ] `client_secret` en tfvars o variables de entorno

---

## 🔧 Validación de Módulos

### Módulos Principales
- [ ] `modules/resource_group/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/storage_account/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/service_bus/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/cosmos_db/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/key_vault/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/api_management/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/signalr/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/vnet/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/log_analytics_workspace/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/function_app/linux/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/function_app/windows/` - main.tf, variables.tf, outputs.tf
- [ ] `modules/front_door/` - main.tf, variables.tf, outputs.tf

---

## 📝 Validación del Root

### Archivos Root
- [ ] `terraform/main.tf` - Incluye todos los módulos
- [ ] `terraform/variables.tf` - Incluye todas las variables
- [ ] `terraform/outputs.tf` - Incluye todos los outputs
- [ ] `terraform/providers.tf` - Configuración de providers

### Integración de Módulos en main.tf
- [ ] `module "resource_group"`
- [ ] `module "storage_account"`
- [ ] `module "service_bus"`
- [ ] `module "cosmos_db"`
- [ ] `module "key_vault"`
- [ ] `module "api_management"`
- [ ] `module "signalr"`
- [ ] `module "vnet"`
- [ ] `module "log_analytics"`
- [ ] `module "function_linux"`
- [ ] `module "azure_functions_windows"`
- [ ] `module "front_door"`

---

## 🎯 Ajustes Necesarios en tfvars

### Nombres Únicos (deben ser globalmente únicos)
- [ ] `storage_accounts.website.name` - Ejemplo: `st<tu-nombre>devweb`
- [ ] `storage_accounts.data.name` - Ejemplo: `st<tu-nombre>devdata`
- [ ] `cosmos_db.account_name` - Ejemplo: `cosmos-<tu-nombre>-dev`
- [ ] `key_vault.name` - Ejemplo: `kv-<tu-nombre>-dev` (max 24 chars)
- [ ] `front_door.name` - Ejemplo: `fd-<tu-nombre>-dev`

### Endpoints de Storage (según región)
- [ ] `front_door.origins.storage_web.host_name`
  - East US: `.z13.web.core.windows.net`
  - East US 2: `.z20.web.core.windows.net`
  - West US: `.z22.web.core.windows.net`

---

## 🚀 Comandos de Validación

### 1. Validar Scripts
```bash
chmod +x scripts/*.sh
./scripts/validate.sh
```

### 2. Verificar Formato
```bash
cd terraform
terraform fmt -recursive
```

### 3. Validar Sintaxis
```bash
terraform validate
```

### 4. Verificar Backend Config
```bash
cat backends/test-dev.tfbackend
# Verificar que los nombres coincidan con lo que creará setup-backend.sh
```

---

## ⚠️ Validaciones Críticas

### Antes de terraform init
- [ ] Backend Storage NO existe aún (se creará con setup-backend.sh)
- [ ] Nombres en tfvars son únicos globalmente
- [ ] Credenciales de Azure configuradas

### Antes de terraform plan
- [ ] Backend Storage creado exitosamente
- [ ] terraform init ejecutado sin errores
- [ ] tfvars editado con valores reales

### Antes de terraform apply
- [ ] Plan revisado completamente
- [ ] Plan muestra "0 to destroy" (en deploy inicial)
- [ ] Recursos a crear son los esperados
- [ ] No hay errores en el plan

---

## 📊 Métricas de Éxito

### Deploy Inicial Mínimo
- Recursos esperados: ~5-7
  - 1 Resource Group
  - 2 Storage Accounts
  - 1 Log Analytics Workspace
  - Otros opcionales

### Deploy Completo
- Recursos esperados: ~30-50
  - Todos los módulos habilitados
  - Functions, Service Bus, Cosmos, etc.

---

## 🐛 Troubleshooting Común

### Error: "Backend initialization required"
```bash
terraform init -backend-config=backends/test-dev.tfbackend -reconfigure
```

### Error: "Name already exists"
```bash
# Cambiar nombres únicos en test-dev.tfvars
```

### Error: "Authentication failed"
```bash
# Verificar credenciales
az login
# O configurar variables de entorno
```

### Plan muestra "to destroy" inesperadamente
```bash
# NO APLICAR - Revisar:
# 1. ¿Cambiaste algún nombre?
# 2. ¿El create flag está correcto?
# 3. terraform state list
```

---

## ✅ Ready to Test

Una vez completado este checklist:

1. ✅ Todos los módulos validados
2. ✅ Archivos de configuración creados
3. ✅ Nombres únicos ajustados
4. ✅ Credenciales configuradas
5. ✅ Scripts de validación pasan

**¡Estás listo para empezar las pruebas!**

Siguiente paso: `docs/TESTING_GUIDE.md`
