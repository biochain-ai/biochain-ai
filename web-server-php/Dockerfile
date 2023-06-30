FROM php:8.1-apache

COPY ./*.php /var/www/html/
COPY composer.json /var/www/html/
#COPY *.html /var/www/html/
# COPY client_secrets.json /var/www/html/
COPY /vendor /var/www/html/vendor

EXPOSE 8080