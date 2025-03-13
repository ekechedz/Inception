FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y nginx openssl

RUN rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
