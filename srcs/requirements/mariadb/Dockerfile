FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y mariadb-server procps

RUN rm -rf /var/lib/apt/lists/*

COPY tools/create_db.sh /usr/local/bin/create_db.sh
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/my.cnf

RUN chmod +x /usr/local/bin/create_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/create_db.sh"]
