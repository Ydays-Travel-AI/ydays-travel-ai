ARG PHP_VERSION
ARG SYMFONY_CLI_URL=https://get.symfony.com/cli/installer
ARG PHP_EXT_INSTALLER_URL=https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions
ARG COMPOSER_VERSION=latest

FROM composer:${COMPOSER_VERSION} AS composer

# ---------------------------------------------------------------------------- #
#                                  DEVELOPMENT                                 #
# ---------------------------------------------------------------------------- #
FROM php:${PHP_VERSION}-cli AS php-symfony
ARG SYMFONY_CLI_URL
ARG PHP_EXT_INSTALLER_URL

# Configures strict shell

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

CMD ["/bin/bash", "-c", \
    "./symfony-preparation.sh dev && \
    rm -rf ~/.symfony*/var/* && \
    symfony server:start --no-tls --allow-all-ip"]

# ---------------------------------------------------------------------------- #
#                                  PRODUCTION                                  #
# ---------------------------------------------------------------------------- #
FROM php:${PHP_VERSION}-fpm AS php-fpm
ARG SYMFONY_CLI_URL
ARG PHP_EXT_INSTALLER_URL

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
    

# Prevent PHP-FPM from warning about 'user' and 'group' directives when not running as root
RUN sed -i 's/^user = .*/; user = www-data/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^group = .*/; group = www-data/' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /app
ENV HOME=/app
RUN chown -R www-data:www-data . &&\
    chmod -R 775 .

# Copying ./symfont and ./.env from root project
COPY --chown=www-data:www-data ./.env ./globalenv
COPY --chown=www-data:www-data symfony .

# Merge symfony vars with global vars
RUN echo >> .env && \
    cat globalenv >> .env && \
    rm globalenv

EXPOSE 9000

RUN chmod u+x ./symfony-preparation.sh && \
    ./symfony-preparation.sh prod

USER www-data