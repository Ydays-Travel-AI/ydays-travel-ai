ARG PHP_VERSION
ARG COMPOSER_VERSION

# # ---------------------------------------------------------------------------- #
# #                                     BASE                                     #
# # ---------------------------------------------------------------------------- #
FROM composer:${COMPOSER_VERSION} AS composer_image

FROM php:${PHP_VERSION}-fpm AS base

RUN apt-get update && apt-get install --quiet=2 --yes --no-install-recommends \
    curl=7.88.1-10+deb12u12 \
    # unzip is better for composer installation
    unzip=6.0-28 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer_image /usr/bin/composer /usr/local/bin/composer

RUN curl -fsSL "https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions" \
    -o /usr/local/bin/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions &&\
    install-php-extensions \
    pdo_mysql \
    gd \
    opcache \
    zip \
    mbstring \
    intl

# ---------------------------------------------------------------------------- #
#                                  DEVELOPMENT                                 #
# ---------------------------------------------------------------------------- #
FROM base AS php-symfony

# Configures strict shell pipes (for better debugging)
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Dev tools
RUN apt-get update && apt-get install --quiet=2 --yes --no-install-recommends \
    git=1:2.39.5-0+deb12u2 \
    npm=9.2.0~ds1-1 &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions xdebug

# CLI symfony
RUN curl -sS "https://get.symfony.com/cli/installer" | bash && \
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
FROM base AS php-fpm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app
RUN chown -R www-data:www-data . &&\
    chmod -R 775 .

# Copying ./symfony and ./.env from root project
COPY --chown=www-data:www-data ./.env ./globalenv
COPY --chown=www-data:www-data symfony .

# Adding global vars to symfony vars
RUN echo >> .env && \
    cat globalenv >> .env && \
    rm globalenv

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

EXPOSE 9000

RUN ./symfony-preparation.sh prod