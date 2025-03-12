#!/bin/bash

# Read passwords from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mdb_root_pw)
MYSQL_PW=$(cat /run/secrets/mdb_pw)

# Debug-Ausgabe
echo "Root Password: $MYSQL_ROOT_PASSWORD"

# Use environment variables directly
MYSQL_USER="$MDB_USER"
MYSQL_DB_NAME="$MDB_DB_NAME"

# Start MariaDB server
mysqld_safe --datadir='/var/lib/mysql' &
until mysqladmin ping -uroot --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

# Setze das Root-Passwort
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"

# Check if database already exists
DB_EXISTS=$(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$MYSQL_DB_NAME'" | grep "$MYSQL_DB_NAME" > /dev/null; echo "$?")

# Create database if it does not exist
if [ "$DB_EXISTS" -eq 1 ]; then
    echo "Database does not exist. Creating database and user..."
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB_NAME\`" || { echo 'Failed to create database'; exit 1; }
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PW'" || { echo 'Failed to create user'; exit 1; }
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;" || { echo 'Failed to grant privileges'; exit 1; }
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" || { echo 'Failed to flush privileges'; exit 1; }
    echo "Database and user created successfully."
else
    echo "Database already exists. Skipping creation."
fi

# Stop the MariaDB service started by the service command
mysqladmin shutdown -uroot -p"$MYSQL_ROOT_PASSWORD"

# Start MariaDB in the foreground to keep the container running
exec mysqld_safe --datadir='/var/lib/mysql'
