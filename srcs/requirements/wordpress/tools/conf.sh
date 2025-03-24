#!/bin/bash

# Define timeout period (10 seconds) to wait for MariaDB to be ready
end_time=$((SECONDS + 10))

# Check if MariaDB is up and running
while (( SECONDS < end_time )); do
    if nc -zq 1 mariadb 3306; then
        echo "[### MARIADB IS UP AND RUNNING ###]"
        break
    else
        echo "[### WAITING FOR MARIADB TO START... ###]"
        sleep 1
    fi
done

# If MariaDB is not responding within the timeout period, print a warning
if (( SECONDS >= end_time )); then
    echo "[### ERROR: MARIADB IS NOT RESPONDING ###]"
    exit 1
fi

# --------------------------------------------------
# INSTALL WordPress CLI (WP-CLI)
# --------------------------------------------------

echo "[### INSTALLING WP-CLI ###]"
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# --------------------------------------------------
# SETUP WordPress
# --------------------------------------------------

echo "[### CONFIGURING WORDPRESS ###]"
cd /var/www/wordpress

# Ensure correct file permissions for security
chmod -R 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress

# Download WordPress core files
wp core download --allow-root

# --------------------------------------------------
# RETRIEVE SECRETS & CONFIGURE DATABASE
# --------------------------------------------------

# Read passwords and credentials from secrets
DB_PASSWORD=$(cat /run/secrets/mdb_pw)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_pw)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_pw)

# Retrieve environment variables for database configuration
MYSQL_DB_NAME="$MDB_DB_NAME"
MYSQL_USER="$MDB_USER"

# Configure WordPress to connect to MariaDB
wp core config --dbhost=mariadb:3306 \
               --dbname="$MYSQL_DB_NAME" \
               --dbuser="$MYSQL_USER" \
               --dbpass="$DB_PASSWORD" \
               --allow-root

# --------------------------------------------------
# INSTALL WORDPRESS & CREATE ADMIN/USER ACCOUNT
# --------------------------------------------------

echo "[### INSTALLING WORDPRESS ###]"
wp core install --url="$DOMAIN_NAME" \
                --title="$WP_TITLE" \
                --admin_user="$WP_ADMIN_NAME" \
                --admin_password="$WP_ADMIN_PASSWORD" \
                --admin_email="$WP_ADMIN_EMAIL" \
                --allow-root

echo "[### CREATING WORDPRESS USER ###]"
wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" \
               --user_pass="$WP_USER_PASSWORD" \
               --role="$WP_USER_ROLE" \
               --allow-root

# --------------------------------------------------
# PHP-FPM CONFIGURATION & START
# --------------------------------------------------

# Modify PHP-FPM configuration to use port 9000 instead of socket file
sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf

# Ensure PHP-FPM run directory exists
mkdir -p /run/php

# Start PHP-FPM in foreground mode to keep the container running
echo "[### STARTING PHP-FPM ###]"
exec /usr/sbin/php-fpm7.4 -F
