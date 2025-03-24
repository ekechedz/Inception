# Use Debian Bullseye as base image
FROM debian:bullseye

# --------------------------------------------------
# SETUP WORKING DIRECTORY
# --------------------------------------------------

# Create directory for WordPress installation
RUN mkdir -p /var/www/wordpress

# --------------------------------------------------
# UPDATE SYSTEM & INSTALL REQUIRED PACKAGES
# --------------------------------------------------

# Update package lists and upgrade installed packages
RUN apt-get update -y && apt-get upgrade -y

# Install required dependencies
RUN apt-get install -y wget php php7.4-fpm php-mysql mariadb-client curl netcat-traditional

# Clean up package lists to reduce image size
RUN rm -rf /var/lib/apt/lists/

# --------------------------------------------------
# COPY CONFIGURATION SCRIPT & SET EXECUTABLE PERMISSIONS
# --------------------------------------------------

# Copy the WordPress configuration script into the container
COPY tools/conf.sh /usr/local/bin/conf.sh

# Make the configuration script executable
RUN chmod +x /usr/local/bin/conf.sh

# --------------------------------------------------
# SET ENTRYPOINT TO START CONFIGURATION SCRIPT
# --------------------------------------------------

ENTRYPOINT ["/usr/local/bin/conf.sh"]
