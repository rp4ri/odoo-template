# Variables
TOFU ?= sudo tofu
TFVARS_FILE ?= tofu.tfvars  # Archivo de variables por defecto
AZURE_ACCOUNT_CMD = az account show --query user --output json
AZURE_USER_CMD = az ad signed-in-user show

# Objetivo por defecto
.DEFAULT_GOAL := help

# Ayuda
help:
	@echo "Comandos disponibles:"
	@echo "  make login         - Iniciar sesión en Azure"
	@echo "  make whoami        - Mostrar usuario autenticado en Azure"
	@echo "  make tofu-init     - Inicializar OpenTofu"
	@echo "  make tofu-plan     - Ver el plan de OpenTofu"
	@echo "  make tofu-apply    - Aplicar cambios con OpenTofu"
	@echo "  make tofu-destroy  - Destruir recursos con OpenTofu"

# Iniciar sesión en Azure
login:
	az login

# Ver usuario autenticado en Azure
whoami:
	@echo "Usuario actual en Azure:"
	@$(AZURE_ACCOUNT_CMD)

# Inicializar OpenTofu
init:
	$(TOFU) init

# Ver plan de ejecución de OpenTofu con variables
plan:
	$(TOFU) plan -var-file=$(TFVARS_FILE)

# Aplicar cambios con OpenTofu usando variables
apply:
	$(TOFU) apply -auto-approve -var-file=$(TFVARS_FILE)

# Destruir recursos con OpenTofu usando variables
destroy:
	$(TOFU) destroy -auto-approve -var-file=$(TFVARS_FILE)

# Obtener la IP pública de la VM
get-ip:
	@az vm show -d -g OdooResourceGroup -n odooVM --query publicIps -o tsv

# Conectarse a la VM con SSH
ssh-vm:
	sudo ssh -i ./id_rsa azureuser@$$(az vm show -d -g OdooResourceGroup -n odooVM --query publicIps -o tsv)