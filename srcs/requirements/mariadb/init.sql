-- Create the WordPress database if it does not already exist
CREATE DATABASE IF NOT EXISTS wordpress;

-- Create a WordPress user with a secure password if the user does not exist
CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED BY 'wordpress_password';

-- Grant all privileges on the WordPress database to the new user
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';

-- Apply the privilege changes immediately
FLUSH PRIVILEGES;
