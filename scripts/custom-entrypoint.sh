#!/bin/bash
set -e

export HIVE_CONF_DIR=/opt/hive/conf

# Tunggu MariaDB siap
echo "Waiting for MariaDB to be ready..."
sleep 10

echo "Checking if we can initialize schema manually..."

# Check if we need to initialize schema
# Try to connect and check if schema exists
if podman exec hive-mariadb mysql -u hive -phivepass metastore -e "SHOW TABLES;" 2>/dev/null | grep -q "VERSION"; then
  echo "Schema already exists, skipping initialization..."
else
  echo "Schema not found, we need to initialize it manually or skip auto-init"
  echo "Starting metastore without schema init (will use datanucleus.schema.autoCreateAll)"
fi

# Start metastore - let datanucleus create schema automatically
echo "Starting Hive Metastore with auto-create schema..."
export HIVE_AUX_JARS_PATH=/opt/hive/lib/mariadb.jar

exec /opt/hive/bin/hive --service metastore