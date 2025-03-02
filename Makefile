# Variables
TOFU ?= opentofu
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
tofu-init:
	$(TOFU) init

# Ver plan de ejecución de OpenTofu
tofu-plan:
	$(TOFU) plan

# Aplicar cambios con OpenTofu
tofu-apply:
	$(TOFU) apply -auto-approve

# Destruir recursos con OpenTofu
tofu-destroy:
	$(TOFU) destroy -auto-approve
