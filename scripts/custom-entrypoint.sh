#!/bin/bash
set -e

export HIVE_CONF_DIR=/opt/hive/conf
export HIVE_AUX_JARS_PATH=/opt/hive/lib/mariadb.jar

# Tunggu MariaDB siap
echo "Waiting for MariaDB to be ready..."
sleep 10

# Pastikan driver ada di tempat yang benar
echo "Ensuring MariaDB driver is accessible..."
if [ ! -f /opt/hive/lib/mariadb.jar ]; then
  echo "ERROR: MariaDB driver not found!"
  exit 1
fi

# Cek apakah schema sudah ada
echo "Checking if schema exists..."
if ! /opt/hive/bin/schematool -dbType mysql -info 2>&1 | grep -q "Hive distribution version"; then
  echo "Schema not found. Initializing..."
  
  # Set HADOOP_CLASSPATH untuk schematool
  export HADOOP_CLASSPATH=/opt/hive/lib/mariadb.jar
  
  # Init schema dengan verbose untuk debugging
  /opt/hive/bin/schematool -dbType mysql -initOrUpgradeSchema -verbose
else
  echo "Schema already exists, skipping initialization..."
fi

# Start metastore dengan environment yang benar
echo "Starting Hive Metastore..."
export HADOOP_CLASSPATH=/opt/hive/lib/mariadb.jar
export CLASSPATH=/opt/hive/lib/mariadb.jar:$CLASSPATH

exec /opt/hive/bin/hive --service metastore