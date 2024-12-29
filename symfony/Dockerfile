# ---------------------------------------------------------------------------- #
#                                  DEVELOPMENT                                 #
# ---------------------------------------------------------------------------- #
ARG PHP_VERSION
FROM php:${PHP_VERSION}-cli as dev-base

RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    unzip \
    libpng-dev \
    libonig-dev \
    curl \
    zip \
    libfreetype6-dev \
    libjpeg-dev &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions &&\
    install-php-extensions \
    pdo_mysql \
    gd \
    opcache \
    zip \
    mbstring \
    xdebug


# ------------------------------- DEV CONTAINER ------------------------------ #
FROM dev-base AS devcontainer
RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    git \
    npm

CMD ["sleep infinity"]
# ------------------------------ DEV CODE RUNNER ----------------------------- #
FROM dev-base AS dev
# CLI symfony
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Xdebug
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    
EXPOSE 8000

# TODO corriger le processus 
CMD ["sh","-c", "composer install && symfony server:start --no-tls --allow-all-ip"]



# ---------------------------------------------------------------------------- #
#                                  PRODUCTION                                  #
# ---------------------------------------------------------------------------- #
ARG PHP_VERSION
FROM php:${PHP_VERSION}-apache as prod

WORKDIR /var/www

RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    unzip \
    libpng-dev \
    libonig-dev \
    curl \
    zip \
    libfreetype6-dev \
    libjpeg-dev &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions &&\
    install-php-extensions \
    pdo_mysql \
    gd \
    opcache \
    zip \
    mbstring
    

COPY --chown=www-data:www-data . .
RUN chown -R www-data:www-data . &&\
    chmod -R 775 .

# Apache configuration
RUN sed -i 's/Listen 80/Listen 8000/' /etc/apache2/ports.conf && \
    echo "LogLevel warn" >> /etc/apache2/apache2.conf &&\
    echo "ServerName localhost" >> /etc/apache2/apache2.conf &&\
    a2dissite 000-default &&\
    mv apache.conf /etc/apache2/sites-available/symfony.conf &&\
    a2ensite symfony
    # a2ensite default-ssl.conf
    
USER www-data

# todo générer un APP_SECRET (impossible sans composer install < .env dans l'image)

EXPOSE 8000

# Required on CMD to have access to .env file
CMD ["sh", "-c", "composer install --no-dev --optimize-autoloader && php bin/console cache:warmup --env=prod && apache2-foreground"]