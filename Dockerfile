# Debian 8 (Jessie), Apache 2.4, PHP 5.6.40
FROM php:5.6-apache

MAINTAINER Lucas Soares <ls6359575@gmail.com>

# XML e GD (imagens)
RUN requirements="libxslt-dev libldap2-dev libmcrypt-dev libpq-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libtidy-dev" \
    && apt-get update && apt-get install -y $requirements \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
	
#Extesoes php 
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-install mcrypt \
    mbstring \
    xsl \
    bcmath \
    calendar \
    exif \
    gettext \
    tidy \
    ldap \
    pcntl \
    posix \
	soap

#Extensao imagick 	
RUN apt-get update && apt-get install -y libmagickwand-6.q16-dev --no-install-recommends \
 && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin \
 && pecl install imagick \
 && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini


#Extensao Banco de Dados
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo_pgsql pgsql


#xDebug 
RUN pecl install xdebug-2.5.5 apcu-4.0.11
RUN docker-php-ext-enable xdebug apcu
	
#VHost
COPY ./docker/emec.conf /etc/apache2/sites-available/000-default.conf
ADD ./docker/php.ini /usr/local/etc/php/conf.d/php-extras.ini


WORKDIR /var/www/html
RUN a2enmod rewrite
EXPOSE 80 9200
