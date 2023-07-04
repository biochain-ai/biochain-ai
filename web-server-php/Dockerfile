FROM php:8.1-apache-buster

# Installa il pacchetto openssl
#RUN apt-get update 
#RUN apt-get install -y --no-install-recommends libssl-dev build-essential

#RUN pecl install openssl
#RUN docker-php-ext-enable openssl

RUN a2enmod ssl

COPY apache.conf /etc/apache2/sites-available/default-ssl.conf
RUN a2ensite default-ssl

RUN sed -i 's/; extension=openssl/extension=openssl/' /usr/local/etc/php/php.ini-production
RUN sed -i 's/; extension=openssl/extension=openssl/' /usr/local/etc/php/php.ini-development

# Copia i certificati SSL nella directory corretta
COPY ssl.crt /etc/apache2/ssl.crt
COPY ssl.key /etc/apache2/ssl.key

COPY ./*.php /var/www/html/
COPY composer.json /var/www/html/
# COPY *.html /var/www/html/
# COPY client_secrets.json /var/www/html/
COPY /vendor /var/www/html/vendor

#COPY ./*.pem /etc/apache2/ssl/
#COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
#RUN service apache2 restart

EXPOSE 8080
# port for ssl 
EXPOSE 443
