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

COPY --chown=www-data:www-data ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint

ENV MODE=dev
ENTRYPOINT ["docker-entrypoint"]
CMD ["symfony","server:start","--no-tls","--allow-all-ip"]

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

COPY --chown=www-data:www-data . .
RUN mv ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint
    
USER www-data

EXPOSE 9000

ENV MODE=prod
ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]