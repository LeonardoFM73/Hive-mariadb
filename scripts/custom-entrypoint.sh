#!/bin/bash
set -e

export HIVE_CONF_DIR=/opt/hive/conf
export HIVE_AUX_JARS_PATH=/opt/hive/lib/mariadb.jar

# Tunggu MariaDB siap
echo "Waiting for MariaDB to be ready..."
sleep 10

# Pastikan driver ada
if [ ! -f /opt/hive/lib/mariadb.jar ]; then
  echo "ERROR: MariaDB driver not found!"
  exit 1
fi

echo "Initializing Hive schema..."

# Set HADOOP_CLASSPATH
export HADOOP_CLASSPATH=/opt/hive/lib/mariadb.jar
export HADOOP_USER_CLASSPATH_FIRST=true

# Cari hive schematool jar
HIVE_SCHEMATOOL_JAR=$(ls /opt/hive/lib/hive-standalone-metastore-*.jar 2>/dev/null | head -1)

if [ -z "$HIVE_SCHEMATOOL_JAR" ]; then
  # Fallback ke hive-schematool jar
  HIVE_SCHEMATOOL_JAR=$(ls /opt/hive/lib/hive-schematool-*.jar 2>/dev/null | head -1)
fi

if [ -n "$HIVE_SCHEMATOOL_JAR" ]; then
  echo "Using JAR: $HIVE_SCHEMATOOL_JAR"
  # Jalankan via hadoop jar command dengan classpath
  /opt/hadoop/bin/hadoop jar "$HIVE_SCHEMATOOL_JAR" org.apache.hive.beeline.schematool.HiveSchemaTool \
    -dbType mysql \
    -initOrUpgradeSchema
else
  # Fallback ke schematool script
  /opt/hive/bin/schematool -dbType mysql -initOrUpgradeSchema
fi

# Start metastore
echo "Starting Hive Metastore..."
exec /opt/hive/bin/hive --service metastore