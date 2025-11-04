FROM apache/hive:4.0.1

USER root

# Copy MariaDB JDBC driver dari host
COPY --chown=hive:hive mariadb-java-client-3.4.0.jar /opt/hadoop/share/hadoop/common/lib/

USER hive