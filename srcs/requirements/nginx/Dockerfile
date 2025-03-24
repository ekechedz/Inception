# Use Debian Bullseye as the base image
FROM debian:bullseye

# Update package lists and upgrade installed packages for security and stability
RUN apt-get update -y && apt-get upgrade -y

# Install NGINX (web server) and OpenSSL (for SSL/TLS certificates)
RUN apt-get install -y nginx openssl

# Remove cached package lists to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Copy the custom NGINX configuration file into the container
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Expose ports 443 (HTTPS) and 80 (HTTP)
EXPOSE 443 80

# Start NGINX in the foreground to keep the container running
CMD ["nginx", "-g", "daemon off;"]
