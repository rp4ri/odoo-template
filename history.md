nota de los comandos usados para desplegar este proyecto tras inicializarlo con make

```docker compose exec odoo odoo -i base,mail,utm,product --stop-after-init
	docker compose exec odoo odoo -i sale --stop-after-init```