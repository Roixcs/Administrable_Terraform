# 🚀 Administrable Terraform - Azure Infrastructure

Infraestructura como código (IaC) para despliegues incrementales en Azure, con gestión multi-cliente.

## 🎯 Características

- ✅ **Incremental:** Agrega recursos sin destruir existentes
- ✅ **Multi-Cliente:** State único por cliente/ambiente
- ✅ **Validación Automática:** Previene destrucción accidental
- ✅ **Modular:** Módulos reutilizables y bien documentados
- ✅ **Simple:** Control con flags `create = true/false`

## 📋 Requisitos

- Terraform >= 1.9.0
- Azure CLI
- Permisos de Contributor en Azure
- Service Principal (para CI/CD)

## 🚀 Quick Start

### 1. Configurar Backend

```bash
# Configurar Storage Account para el state
./scripts/setup-backend-storage.sh
```

### 2. Crear Configuración del Cliente

```bash
# Copiar templates
cp terraform/backends/clienteA-dev.tfbackend.example terraform/backends/micliente-dev.tfbackend
cp terraform/environments/clienteA-dev.tfvars.example terraform/environments/micliente-dev.tfvars

# Editar con tus valores
vim terraform/environments/micliente-dev.tfvars
```

### 3. Desplegar

```bash
# Inicializar
make init CLIENT=micliente ENV=dev

# Validar (IMPORTANTE)
make validate-incremental CLIENT=micliente ENV=dev

# Aplicar
make apply CLIENT=micliente ENV=dev
```

## 📖 Documentación

- [Flujo Incremental](docs/INCREMENTAL_WORKFLOW.md) - Guía Día 1 → Día 30
- [Guía de Módulos](docs/MODULE_GUIDE.md) - Cómo usar cada módulo
- [Naming Convention](docs/NAMING_CONVENTION.md) - Estándares de nombres
- [FAQ](docs/FAQ.md) - Preguntas frecuentes

## 🏗️ Recursos Soportados

- Resource Groups
- Azure Functions (Windows & Linux)
- Storage Accounts
- Service Bus (Queues & Topics)
- Cosmos DB (Serverless)
- API Management
- Key Vault
- SignalR Service
- Virtual Networks
- Front Door

## 📊 Estructura del Proyecto

```
Administrable_Terraform/
├── terraform/
│   ├── main.tf              # Orquestación principal
│   ├── variables.tf         # Variables del root
│   ├── backends/            # Configs de backend por cliente
│   ├── environments/        # tfvars por cliente/ambiente
│   └── modules/             # Módulos reutilizables
├── scripts/                 # Scripts de automatización
└── docs/                    # Documentación
```

## 🎯 Filosofía de Uso

### Un archivo tfvars = Un cliente/ambiente

```hcl
# environments/clienteA-dev.tfvars

# Control con flags
resource_group = { create = true, name = "..." }
service_bus    = { create = true, ... }
cosmos_db      = { create = false, ... }  # Activar después

# Arrays para recursos múltiples
functions_linux = [
  { name = "fn-1", ... },
  { name = "fn-2", ... },
  # Agregar más cuando sea necesario
]
```

### Expansión Incremental

```bash
# Día 1: Desplegar inicial
make deploy CLIENT=clienteA ENV=dev

# Día 30: Editar tfvars (cambiar create=false a true, agregar functions)
vim terraform/environments/clienteA-dev.tfvars

# Validar (debe mostrar: 0 to destroy)
make validate-incremental CLIENT=clienteA ENV=dev

# Aplicar
make apply CLIENT=clienteA ENV=dev
```

## ⚠️ Reglas Críticas

### ✅ QUÉ SÍ HACER:
1. Activar servicios: `create = false` → `create = true`
2. Agregar functions al array
3. Validar SIEMPRE antes de aplicar
4. Hacer backup del state antes de cambios grandes

### ❌ QUÉ NO HACER:
1. NUNCA: `create = true` → `create = false` (destruye)
2. NUNCA: Eliminar functions del array (las destruye)
3. NUNCA: Aplicar sin validar
4. NUNCA: Cambiar nombres de recursos existentes

## 🛠️ Comandos Útiles

```bash
# Ver todos los comandos disponibles
make help

# Validar incrementalidad
make validate-incremental CLIENT=clienteA ENV=dev

# Ver recursos actuales
make state-list CLIENT=clienteA ENV=dev

# Backup del state
make state-pull CLIENT=clienteA ENV=dev

# Listar clientes configurados
make list-clients
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una branch: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -am 'Agrega nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Crea un Pull Request

## 📝 License

Este proyecto está bajo la licencia MIT.

## 📞 Soporte

- 📖 Documentación: [docs/](docs/)
- 🐛 Issues: [GitHub Issues](https://github.com/Roixcs/Administrable_Terraform/issues)
- 💬 Discusiones: [GitHub Discussions](https://github.com/Roixcs/Administrable_Terraform/discussions)

---

**Construido con ❤️ para infraestructura escalable y mantenible**