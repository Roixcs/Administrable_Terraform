#!/bin/bash

# ============================================
# Script de Testing de Infraestructura Terraform
# ============================================

set -e  # Exit on error

# Colors para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
TERRAFORM_DIR="terraform"
BACKEND_CONFIG="state.tfbackend"
SCENARIOS_DIR="environments"

# Función para logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para mostrar header
show_header() {
    echo ""
    echo "============================================"
    echo "$1"
    echo "============================================"
    echo ""
}

# Función para confirmar acción
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Operación cancelada por el usuario"
        exit 1
    fi
}

# Función para inicializar Terraform
init_terraform() {
    local state_key=$1
    show_header "Inicializando Terraform con state: $state_key"
    
    cd $TERRAFORM_DIR
    
    # Backup del backend config
    cp $BACKEND_CONFIG "${BACKEND_CONFIG}.bak"
    
    # Modificar el key en el backend config
    sed -i "s|key.*=.*\".*\"|key = \"$state_key\"|g" $BACKEND_CONFIG
    
    log_info "Ejecutando terraform init..."
    if terraform init -backend-config="$BACKEND_CONFIG" -reconfigure; then
        log_success "Terraform inicializado correctamente"
    else
        log_error "Error al inicializar Terraform"
        exit 1
    fi
    
    cd ..
}

# Función para validar configuración
validate_terraform() {
    show_header "Validando Configuración de Terraform"
    
    cd $TERRAFORM_DIR
    
    log_info "Ejecutando terraform validate..."
    if terraform validate; then
        log_success "Configuración válida"
    else
        log_error "Configuración inválida"
        exit 1
    fi
    
    cd ..
}

# Función para ejecutar plan
plan_scenario() {
    local scenario_file=$1
    local output_file=$2
    
    show_header "Ejecutando Plan: $scenario_file"
    
    cd $TERRAFORM_DIR
    
    log_info "Generando plan de ejecución..."
    if terraform plan -var-file="../$SCENARIOS_DIR/$scenario_file" -out="$output_file"; then
        log_success "Plan generado: $output_file"
        
        # Mostrar resumen del plan
        echo ""
        log_info "Resumen del Plan:"
        terraform show -no-color "$output_file" | grep -E "Plan:|No changes"
        echo ""
    else
        log_error "Error al generar el plan"
        exit 1
    fi
    
    cd ..
}

# Función para aplicar plan
apply_plan() {
    local plan_file=$1
    
    show_header "Aplicando Plan: $plan_file"
    
    confirm "¿Está seguro que desea aplicar este plan?"
    
    cd $TERRAFORM_DIR
    
    log_info "Aplicando cambios..."
    if terraform apply "$plan_file"; then
        log_success "Cambios aplicados correctamente"
        
        # Mostrar outputs
        echo ""
        log_info "Outputs de la infraestructura:"
        terraform output
        echo ""
    else
        log_error "Error al aplicar los cambios"
        exit 1
    fi
    
    cd ..
}

# Función para aplicar sin plan previo
apply_auto() {
    local scenario_file=$1
    
    show_header "Aplicando Scenario: $scenario_file"
    
    confirm "¿Está seguro que desea aplicar los cambios automáticamente?"
    
    cd $TERRAFORM_DIR
    
    log_info "Aplicando cambios..."
    if terraform apply -var-file="../$SCENARIOS_DIR/$scenario_file" -auto-approve; then
        log_success "Cambios aplicados correctamente"
        
        # Mostrar outputs
        echo ""
        log_info "Outputs de la infraestructura:"
        terraform output
        echo ""
    else
        log_error "Error al aplicar los cambios"
        exit 1
    fi
    
    cd ..
}

# Función para destruir recursos
destroy_scenario() {
    local scenario_file=$1
    
    show_header "Destruyendo Recursos: $scenario_file"
    
    log_warning "¡ADVERTENCIA! Esta acción destruirá TODOS los recursos de este scenario"
    confirm "¿Está COMPLETAMENTE seguro?"
    
    cd $TERRAFORM_DIR
    
    log_info "Destruyendo recursos..."
    if terraform destroy -var-file="../$SCENARIOS_DIR/$scenario_file" -auto-approve; then
        log_success "Recursos destruidos correctamente"
    else
        log_error "Error al destruir los recursos"
        exit 1
    fi
    
    cd ..
}

# Función para mostrar estado actual
show_state() {
    show_header "Estado Actual de la Infraestructura"
    
    cd $TERRAFORM_DIR
    
    log_info "Recursos en el estado:"
    terraform state list
    
    echo ""
    log_info "Outputs actuales:"
    terraform output
    
    cd ..
}

# Función para test completo de un scenario
test_scenario_complete() {
    local scenario_name=$1
    local scenario_file=$2
    local state_key=$3
    
    show_header "TEST COMPLETO: $scenario_name"
    
    # 1. Inicializar
    init_terraform "$state_key"
    
    # 2. Validar
    validate_terraform
    
    # 3. Plan
    plan_scenario "$scenario_file" "plan-${scenario_name}.tfplan"
    
    # 4. Confirmar y aplicar
    confirm "¿Desea aplicar este plan?"
    apply_plan "plan-${scenario_name}.tfplan"
    
    # 5. Verificar
    show_state
    
    log_success "Test completo de $scenario_name finalizado"
    
    # 6. Preguntar si destruir
    echo ""
    read -p "¿Desea destruir los recursos ahora? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        destroy_scenario "$scenario_file"
    else
        log_warning "Recursos mantenidos. Recuerde destruirlos manualmente para evitar costos."
    fi
}

# Menú principal
show_menu() {
    clear
    show_header "🧪 TESTING MENU - Infraestructura Terraform"
    
    echo "Seleccione una opción:"
    echo ""
    echo "=== Tests Rápidos ==="
    echo "1) Test Completo - Scenario 1 (Minimal)"
    echo "2) Test Completo - Scenario 2 (Standard)"
    echo "3) Test Completo - Scenario 3 (Complete)"
    echo ""
    echo "=== Operaciones Individuales ==="
    echo "4) Solo Init + Validate"
    echo "5) Solo Plan (especificar scenario)"
    echo "6) Solo Apply (especificar scenario)"
    echo "7) Solo Destroy (especificar scenario)"
    echo "8) Ver Estado Actual"
    echo ""
    echo "=== Tests Avanzados ==="
    echo "9) Test de Ciclo de Vida (agregar recursos)"
    echo "10) Test de Aislamiento (múltiples scenarios)"
    echo ""
    echo "0) Salir"
    echo ""
    read -p "Opción: " option
    
    case $option in
        1)
            test_scenario_complete "scenario-1" "test-scenario-1-minimal.tfvars" "scenario-1-minimal.tfstate"
            ;;
        2)
            test_scenario_complete "scenario-2" "test-scenario-2-standard.tfvars" "scenario-2-standard.tfstate"
            ;;
        3)
            test_scenario_complete "scenario-3" "test-scenario-3-complete.tfvars" "scenario-3-complete.tfstate"
            ;;
        4)
            read -p "State key: " state_key
            init_terraform "$state_key"
            validate_terraform
            ;;
        5)
            read -p "Scenario file (ej: test-scenario-1-minimal.tfvars): " scenario_file
            read -p "Output file (ej: plan.tfplan): " output_file
            plan_scenario "$scenario_file" "$output_file"
            ;;
        6)
            read -p "Scenario file: " scenario_file
            apply_auto "$scenario_file"
            ;;
        7)
            read -p "Scenario file: " scenario_file
            destroy_scenario "$scenario_file"
            ;;
        8)
            show_state
            ;;
        9)
            log_info "Iniciando test de ciclo de vida..."
            # Test personalizado aquí
            ;;
        10)
            log_info "Iniciando test de aislamiento..."
            # Test de múltiples scenarios
            ;;
        0)
            log_info "Saliendo..."
            exit 0
            ;;
        *)
            log_error "Opción inválida"
            ;;
    esac
    
    echo ""
    read -p "Presione Enter para continuar..."
    show_menu
}

# Main
main() {
    # Verificar que estamos en el directorio correcto
    if [ ! -d "$TERRAFORM_DIR" ]; then
        log_error "Directorio $TERRAFORM_DIR no encontrado"
        log_error "Ejecute este script desde la raíz del proyecto"
        exit 1
    fi
    
    # Verificar que terraform está instalado
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform no está instalado"
        exit 1
    fi
    
    log_success "Terraform encontrado: $(terraform version | head -n 1)"
    
    # Mostrar menú
    show_menu
}

# Ejecutar
main