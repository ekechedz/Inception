#!/bin/bash

# Function to generate a random password
generate_password() {
  openssl rand -base64 12
}

# Function to create directories, remove them if they already exist, and then recreate them
create_directory() {
  local DIR=$1
  echo -e "\e[34mChecking directory: $DIR...\e[0m"
  if [ -d "$DIR" ]; then
    rm -rf "$DIR"
    echo -e "\e[33m✔ \e[0mDirectory $DIR removed."
  fi
  mkdir -p "$DIR"
  echo -e "\e[32m✔ \e[0mDirectory $DIR created."
}

# Function to print success messages with custom colors
print_success() {
  echo -e "\e[32m✔ \e[0m$1"
}

# Function to print warning messages with custom colors
print_warning() {
  echo -e "\e[33m⚠ \e[0m$1"
}

# Function to print error messages with custom colors
print_error() {
  echo -e "\e[31m✖ \e[0m$1"
}

# CREATE WORDPRESS DIRECTORY
create_directory "/home/ekechedz/data/wordpress"

# CREATE MARIADB DIRECTORY
create_directory "/home/ekechedz/data/mariadb"

# CREATE SECRETS DIRECTORY, REMOVE IT IF EXISTING, AND GENERATE PASSWORDS
create_directory "./secrets"
mkdir -m 775 "./secrets"  # Set the correct permissions for the secrets directory
print_success "Secrets directory created with correct permissions."

# Generate random passwords for secrets
generate_password > "./secrets/wp_user_password.txt"
generate_password > "./secrets/wp_root_password.txt"
generate_password > "./secrets/db_password.txt"
generate_password > "./secrets/db_root_password.txt"
print_success "Secrets files created."

# CREATE SSL CERTIFICATES IF THEY DON'T EXIST
echo -e "\e[34mChecking for existing SSL certificates...\e[0m"
if [ -f "./secrets/inception.crt" ] || [ -f "./secrets/inception.key" ]; then
  rm -f "./secrets/inception.crt" "./secrets/inception.key"
  print_warning "Existing SSL certificates removed."
fi

# Now create the new SSL certificates
openssl req -x509 -nodes -out "./secrets/inception.crt" -keyout "./secrets/inception.key" -subj "/C=DE/ST=IDF/L=BERLIN/O=42/OU=42/CN=ekechedz.42.fr/UID=ekechedz.42.fr" 2> /dev/null
print_success "SSL certificates created."

# SET PERMISSIONS FOR SSL CERTIFICATES
chmod 644 "./secrets/inception.crt"
chmod 644 "./secrets/inception.key"
print_success "SSL certificates permissions set."

# CREATE ENV VARIABLES, REMOVE .env FILE IF EXISTING, AND CREATE A NEW ONE
ENV_FILE="srcs/.env"
echo -e "\e[34mChecking for existing .env file...\e[0m"
if [ -f "$ENV_FILE" ]; then
  rm -f "$ENV_FILE"
  print_warning ".env file removed."
fi

# Create the .env file with necessary environment variables for WordPress and MariaDB
{
  echo "DOMAIN_NAME=ekechedz.42.fr"
  echo "#mariadb"
  echo "MDB_USER=ekechedz"
  echo "MDB_DB_NAME=database"
  echo "#wordpress"
  echo "WP_TITLE=inception"
  echo "WP_ADMIN_NAME=ekechedz"
  echo "WP_ADMIN_EMAIL=ekechedz@gmail.com"
  echo "WP_USER_NAME=user"
  echo "WP_USER_EMAIL=user@gmail.com"
  echo "WP_USER_ROLE=author"
} > "$ENV_FILE"
print_success ".env file created."
