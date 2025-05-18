ARG PHP_VERSION
ARG SYMFONY_CLI_URL=https://get.symfony.com/cli/installer
ARG PHP_EXT_INSTALLER_URL=https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions
ARG COMPOSER_VERSION=latest

FROM composer:${COMPOSER_VERSION} AS composer

# ---------------------------------------------------------------------------- #
#                                  DEVELOPMENT                                 #
# ---------------------------------------------------------------------------- #
FROM php:${PHP_VERSION}-fpm AS php-symfony
ARG SYMFONY_CLI_URL
ARG PHP_EXT_INSTALLER_URL

# Configures strict shell pipes (for better debugging)
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN curl -fsSL "${PHP_EXT_INSTALLER_URL}" -o /usr/local/bin/install-php-extensions
RUN chmod +x /usr/local/bin/install-php-extensions &&\
    install-php-extensions \
    pdo_mysql \
    gd \
    opcache \
    zip \
    mbstring \
    xdebug \
    intl

# Dev tools
# hadolint ignore=DL3008
RUN apt-get update &&\
    apt-get install -qq -y --no-install-recommends \
    git \
    npm &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

# CLI symfony
RUN curl -sS "${SYMFONY_CLI_URL}" | bash && \
    mv "$HOME/.symfony5/bin/symfony" /usr/local/bin/symfony

# PHP configurations
RUN  echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

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
    curl &&\
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
    intl

WORKDIR /app
ENV HOME=/app
RUN chown -R www-data:www-data . &&\
    chmod -R 775 .

# Copying ./symfont and ./.env from root project
COPY --chown=www-data:www-data ./.env ./globalenv
COPY --chown=www-data:www-data symfony .

# Adding global vars to symfony vars
RUN echo >> .env && \
    cat globalenv >> .env && \
    rm globalenv

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

EXPOSE 9000

RUN ./symfony-preparation.sh prod