# Use Debian Bullseye as the base image
FROM debian:bullseye

# Update and upgrade existing packages to ensure security and stability
RUN apt-get update -y && apt-get upgrade -y

# Install MariaDB server and procps
RUN apt-get install -y mariadb-server procps

# Remove cached package lists to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Copy the database initialization script into the container
COPY tools/create_db.sh /usr/local/bin/create_db.sh

# Copy the custom MariaDB configuration file
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/my.cnf

# Ensure the database initialization script is executable
RUN chmod +x /usr/local/bin/create_db.sh

# Expose port 3306 to allow database connections
EXPOSE 3306

# Set the entrypoint to the database initialization script
ENTRYPOINT ["/usr/local/bin/create_db.sh"]
