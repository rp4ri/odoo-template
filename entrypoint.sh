#!/bin/sh
set -e

if ! command -v envsubst >/dev/null 2>&1; then
    apt update && apt install -y gettext
fi

echo "Generando odoo.conf..."
envsubst < /etc/odoo/odoo.template.conf > /etc/odoo/odoo.conf

echo "Contenido de odoo.conf:"
cat /etc/odoo/odoo.conf


check_db_initialized() {
    psql -h $PGHOST -U $PGUSER -d $PGDATABASE -c "SELECT 1 FROM ir_module_module WHERE name='base' AND state='installed'" | grep -q 1
}

if ! check_db_initialized; then
    echo "Initializing Odoo database..."
    odoo -c /etc/odoo/odoo.conf -i base --stop-after-init
    echo "Database initialization complete."
fi


echo "Starting Odoo..."

exec "$@"