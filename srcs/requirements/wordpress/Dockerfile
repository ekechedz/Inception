FROM debian:bullseye

RUN mkdir -p /var/www/wordpress

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y wget php php7.4-fpm php-mysql mariadb-client curl netcat-traditional

RUN rm -rf /var/lib/apt/lists/

COPY tools/conf.sh /usr/local/bin/wordpress_conf.sh

RUN chmod +x /usr/local/bin/wordpress_conf.sh

ENTRYPOINT ["/usr/local/bin/wordpress_conf.sh"]
