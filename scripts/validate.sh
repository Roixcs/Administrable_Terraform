#!/bin/bash
# ============================================
# Validación Rápida de Terraform
# ============================================

set -e

cd "$(dirname "$0")/../terraform" || exit 1

echo "=========================================="
echo "Validación de Infraestructura Terraform"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función de check
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
        exit 1
    fi
}

# 1. Verificar Terraform instalado
echo "1. Verificando Terraform..."
terraform version > /dev/null 2>&1
check "Terraform instalado"

# 2. Verificar Azure CLI
echo "2. Verificando Azure CLI..."
az version > /dev/null 2>&1
check "Azure CLI instalado"

# 3. Verificar autenticación
echo "3. Verificando autenticación Azure..."
az account show > /dev/null 2>&1
check "Autenticado en Azure"

# 4. Verificar estructura de módulos
echo "4. Verificando módulos..."
modules=(
    "resource_group"
    "storage_account"
    "service_bus"
    "cosmos_db"
    "key_vault"
    "api_management"
    "signalr"
    "vnet"
    "log_analytics_workspace"
    "function_app/linux"
    "function_app/windows"
    "front_door"
)

for module in "${modules[@]}"; do
    if [ -d "modules/$module" ]; then
        echo -e "  ${GREEN}✅${NC} $module"
    else
        echo -e "  ${RED}❌${NC} $module"
        exit 1
    fi
done

# 5. Verificar archivos de configuración
echo "5. Verificando archivos de configuración..."
files=(
    "main.tf"
    "variables.tf"
    "outputs.tf"
    "providers.tf"
    "environments/test-dev.tfvars"
    "backends/test-dev.tfbackend"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅${NC} $file"
    else
        echo -e "  ${YELLOW}⚠️${NC}  $file (falta)"
    fi
done

# 6. Validar sintaxis
echo "6. Validando sintaxis de Terraform..."
terraform fmt -check -recursive > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Formato correcto${NC}"
else
    echo -e "${YELLOW}⚠️  Ejecuta: terraform fmt -recursive${NC}"
fi

terraform validate -json > /dev/null 2>&1
check "Sintaxis válida"

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Validación completada exitosamente${NC}"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "  1. Configurar backend: ./scripts/setup-backend.sh"
echo "  2. Inicializar: terraform init -backend-config=backends/test-dev.tfbackend"
echo "  3. Planear: terraform plan -var-file=environments/test-dev.tfvars"
echo ""
