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

echo "Initializing Hive schema directly with Java..."

# Jalankan schematool langsung dengan java dan classpath yang eksplisit
# Ini adalah cara paling pasti untuk memastikan driver dimuat
SCHEMA_JAR=$(ls /opt/hive/lib/hive-standalone-metastore-*.jar 2>/dev/null | head -1)

if [ -z "$SCHEMA_JAR" ]; then
  # Jika tidak ada standalone jar, gunakan semua jar
  java -cp "/opt/hive/lib/*:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hive/lib/mariadb.jar" \
    org.apache.hive.beeline.schematool.HiveSchemaTool \
    -dbType mysql \
    -initOrUpgradeSchema
else
  # Gunakan standalone jar
  java -cp "$SCHEMA_JAR:/opt/hive/lib/mariadb.jar:/opt/hive/lib/*" \
    org.apache.hive.beeline.schematool.HiveSchemaTool \
    -dbType mysql \
    -initOrUpgradeSchema
fi

# Start metastore
echo "Starting Hive Metastore..."
export HADOOP_CLASSPATH=/opt/hive/lib/mariadb.jar

exec /opt/hive/bin/hive --service metastore