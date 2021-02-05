FROM suhoag/stickcandy-dev:nginx-base

ENV PHP_VERSION 7.2

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
        php$PHP_VERSION-mysql \
        php$PHP_VERSION-mbstring \
        php$PHP_VERSION-zip \
        php$PHP_VERSION-curl \
        php$PHP_VERSION-xml \
        php$PHP_VERSION-bcmath \
        php$PHP_VERSION-xdebug \
        php$PHP_VERSION-gd

# php install
RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php$PHP_VERSION \
        php$PHP_VERSION-fpm \
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
    && sed -i 's/;date.timezone =/date.timezone = Asia\/Seoul/g' /etc/php/$PHP_VERSION/fpm/php.ini \
    && sed -i 's/;date.timezone =/date.timezone = Asia\/Seoul/g' /etc/php/$PHP_VERSION/cli/php.ini \
    && sed -i 's/error_reporting.*/error_reporting = E_ALL/g' /etc/php/$PHP_VERSION/fpm/php.ini \
    && sed -i 's/error_reporting.*/error_reporting = E_ALL/g' /etc/php/$PHP_VERSION/cli/php.ini \
    && sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/$PHP_VERSION/fpm/php.ini \
    && sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/$PHP_VERSION/cli/php.ini

RUN set -eux \
# 설정 파일 전달
    && cp -f /config/xdebug.ini /etc/php/$PHP_VERSION/mods-available/xdebug.ini \
# fpm pid 생성용 디렉토리 생성
    && mkdir /run/php \
    && cp -f /config/entrypoint.sh /entrypoint.sh \
    && chmod +x /entrypoint.sh \

# build시 사용한 임시 폴더 정리
    && rm -fr /config \
    && rm -fr /tmp/*