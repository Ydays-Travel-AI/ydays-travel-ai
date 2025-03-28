ARG PHP_VERSION
ARG SYMFONY_CLI_URL=https://get.symfony.com/cli/installer
ARG PHP_EXT_INSTALLER_URL=https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions

ARG COMPOSER_VERSION=latest
FROM composer:${COMPOSER_VERSION} AS composer

# ---------------------------------------------------------------------------- #
#                                  DEVELOPMENT                                 #
# ---------------------------------------------------------------------------- #
FROM php:${PHP_VERSION}-cli AS dev
ARG SYMFONY_CLI_URL
ARG PHP_EXT_INSTALLER_URL

# Configures strict shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
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

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN curl -fsSL "${PHP_EXT_INSTALLER_URL}" -o /usr/local/bin/install-php-extensions
RUN chmod +x /usr/local/bin/install-php-extensions &&\
    install-php-extensions \
    pdo_mysql \
    gd \
    opcache \
    zip \
    mbstring \
    xdebug

# Dev tools
# hadolint ignore=DL3008
RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    git \
    npm

# CLI symfony
RUN curl -sS "${SYMFONY_CLI_URL}" | bash && \
    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Xdebug
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    
EXPOSE 8000

WORKDIR /var/www/symfony

CMD ["sh", "-c", "./generate-app-secret.sh &&\
    composer install &&\
    rm -rf ~/.symfony5/var/* &&\
    symfony server:start --no-tls --allow-all-ip"]
# ---------------------------------------------------------------------------- #
#                                  PRODUCTION                                  #
# ---------------------------------------------------------------------------- #
FROM php:${PHP_VERSION}-apache AS prod
ARG SYMFONY_CLI_URL
ARG PHP_EXT_INSTALLER_URL

WORKDIR /var/www

# hadolint ignore=DL3008
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

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN curl -fsSL "${PHP_EXT_INSTALLER_URL}" -o /usr/local/bin/install-php-extensions

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

EXPOSE 8000

# Needs .env
CMD ["sh", "-c", "./generate-app-secret.sh &&\
    composer install --no-dev --optimize-autoloader &&\
    php bin/console cache:warmup --env=prod &&\
    composer dump-env prod &&\
    apachectl -D FOREGROUND"]