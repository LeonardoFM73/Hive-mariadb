#!/bin/bash
set -e

# Export classpath dengan driver MariaDB
export HADOOP_CLASSPATH=/opt/hive/lib/mariadb.jar:${HADOOP_CLASSPATH}
export CLASSPATH=/opt/hive/lib/mariadb.jar:${CLASSPATH}
export HIVE_CONF_DIR=/opt/hive/conf

# Tunggu MariaDB siap (simple wait)
echo "Waiting for MariaDB to be ready..."
sleep 10

# Inisialisasi schema
echo "Initializing Hive schema with driver in classpath..."
/opt/hive/bin/schematool -dbType mysql -initOrUpgradeSchema

# Start metastore service
echo "Starting Hive Metastore..."
exec /opt/hive/bin/hive --service metastore