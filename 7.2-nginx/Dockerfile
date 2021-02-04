FROM stickcandy-dev:nginx-base

# docker 빌드에 필요한 파일 전송
COPY config /config

RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \

# php ppa add
    && savedAptMark="$(apt-mark showmanual)" \
    && apt-get update \
    && apt-get install -y apt-utils dialog lsb-release --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && apt-mark auto '.*' > /dev/null \
    && [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark \
    && find /usr/local -type f -executable -exec ldd '{}' ';' \
            | awk '/=>/ { print $(NF-1) }' \
            | sort -u \
            | xargs -r dpkg-query --search \
            | cut -d: -f1 \
            | sort -u \
            | xargs -r apt-mark manual \
    \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

ENV PHP_MODULE_LISTS \
        php7.2-mysql \
        php7.2-mbstring \
        php7.2-zip \
        php7.2-curl \
        php7.2-xml \
        php7.2-bcmath \
        php7.2-xdebug \
        php7.2-gd

# php install
RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php7.2 \
        php7.2-fpm \
        ${PHP_MODULE_LISTS:-} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# composer 설치
RUN set -eux \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer

RUN set -eux \
    && sed -i 's/;date.timezone =/date.timezone = Asia\/Seoul/g' /etc/php/7.2/fpm/php.ini \
    && sed -i 's/error_reporting.*/error_reporting = E_ALL/g' /etc/php/7.2/cli/php.ini \
    && sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/7.2/cli/php.ini

RUN set -eux \
# 설정 파일 전달
    && cat /config/supervisord.conf >> /etc/supervisor/supervisord.conf \
    && cp -f /config/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini \

# build시 사용한 임시 폴더 정리
    && rm -fr /config \
    && rm -fr /tmp/*