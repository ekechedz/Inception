#!/bin/bash

# Load passwords from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mdb_root_pw)
MYSQL_PW=$(cat /run/secrets/mdb_pw)

# Environment variables
MYSQL_USER="${MDB_USER}"
MYSQL_DB_NAME="${MDB_DB_NAME}"

# Debug output (remove in production)
echo "Starting MariaDB setup..."
echo "Root Password Loaded"
echo "Root password: ${MYSQL_ROOT_PASSWORD}"

# Start MariaDB server in the background
mysqld_safe --datadir='/var/lib/mysql' &

# Wait for MariaDB to be available
until mysqladmin ping -uroot --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

# Set root password
mysql -uroot -e "
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;"

# Check if the database exists
if ! mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${MYSQL_DB_NAME}" &>/dev/null; then
    echo "Database does not exist. Creating database and user..."

    mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOF
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB_NAME}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PW}';
        GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
EOF

    echo "Database and user created successfully."
else
    echo "Database '${MYSQL_DB_NAME}' already exists. Skipping creation."
fi

# Shutdown MariaDB gracefully
mysqladmin shutdown -uroot -p"${MYSQL_ROOT_PASSWORD}"

# Restart MariaDB in the foreground to keep the container running
exec mysqld_safe --datadir='/var/lib/mysql'
