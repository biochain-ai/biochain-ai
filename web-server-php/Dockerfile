FROM php:8.1-apache

COPY ./*.php /var/www/html/
COPY composer.json /var/www/html/
# COPY *.html /var/www/html/
# COPY client_secrets.json /var/www/html/
COPY /vendor /var/www/html/vendor

## ssl cert and key
COPY ssl.crt /etc/apache2/ssl/ssl.crt
COPY ssl.key /etc/apache2/ssl/ssl.key

# Change ssl conf file
RUN   sed -i "s|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/apache2/ssl/ssl.crt|g" /etc/apache2/sites-available/default-ssl.conf
RUN   sed -i "s|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/apache2/ssl/ssl.key|g" /etc/apache2/sites-available/default-ssl.conf

RUN ln -s /etc/apache2/mods-available/ssl.load  /etc/apache2/mods-enabled/ssl.load

EXPOSE 8080
# port for ssl 
EXPOSE 443