# --------------------------------------------------------------
ARG PHP_VERSION
FROM php:${PHP_VERSION} AS dev

WORKDIR /var/www

# Install libs
RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    unzip \
    libpng-dev \
    libonig-dev \
    git
RUN apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions &&\
    install-php-extensions \
    pdo_mysql \
    gd \
    opcache \
    zip \
    mbstring \
    xdebug

# CLI symfony
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Xdebug
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    
EXPOSE 8000

CMD ["sh","-c", "composer install && symfony server:start --no-tls --allow-all-ip"]

# --------------------------------------------------------------
ARG PHP_VERSION
FROM php:${PHP_VERSION}-apache AS prod

WORKDIR /var/www

RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    libpng-dev \
    libonig-dev
RUN apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# Installer Composer
COPY --from=composer:2.1 /usr/bin/composer /usr/local/bin/composer

# Installer les extensions PHP via install-php-extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions &&\
    install-php-extensions \
    pdo_mysql \
    gd \
    opcache \
    zip \
    mbstring 
    
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo "LogLevel error" >> /etc/apache2/apache2.conf

COPY --chown=www-data:www-data . .

RUN chown -R www-data:www-data . &&\
    chmod -R 775 .

RUN mv apache.conf /etc/apache2/sites-enabled &&\
    rm /etc/apache2/sites-enabled/000-default.conf
    # a2ensite default-ssl.conf
    
USER www-data

# todo générer un APP_SECRET

CMD ["sh", "-c", "composer install --no-dev --optimize-autoloader && php bin/console cache:warmup --env=prod && apache2-foreground"]