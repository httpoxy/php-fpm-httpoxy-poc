FROM php:7.0.8-apache

COPY . /var/www/html/
WORKDIR /var/www/html

RUN apt-get update && apt-get install -y git zip unzip

RUN curl -sS https://getcomposer.org/installer | php
RUN ./composer.phar install
