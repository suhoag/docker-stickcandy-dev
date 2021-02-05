FROM debian:buster-slim

# docker 빌드에 필요한 파일 전송
COPY config /config

ENV HOME /var/www

RUN set -eux \

# 한국 시간 세팅
    && ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime \
    && echo "Asia/Seoul" > /etc/timezone \

# ll alias 추가
    && echo "alias ll='ls -alF'" >> /etc/bash.bashrc

RUN set -eux \

# 설치시 interactive 대기를 타지 않도록 수정
    && export DEBIAN_FRONTEND=noninteractive \

# basic package install
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        wget \
        git \
        vim \
        ca-certificates \
        procps \
        apt-utils \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux \

# nginx ppa add
    && savedAptMark="$(apt-mark showmanual)" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        gnupg2 \
        lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - \
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

RUN set -eux \

# nginx install
    && apt-get update \
    && apt-get install -y --no-install-recommends \
            nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \

# 설정 파일 전달
    && cp -f /config/entrypoint.sh /entrypoint.sh \
    && chmod +x /entrypoint.sh \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
    && sed -i 's/user.*nginx\;/user www-data\;/g' /etc/nginx/nginx.conf \

# apt 정리
    && apt-get autoclean -y \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \

# build시 사용한 임시 폴더 정리
    && rm -fr /config \
    && rm -fr /tmp/*

# ENTRYPOINT 지정
ENTRYPOINT ["/entrypoint.sh"]

# 볼륨 지정
VOLUME ["/var/www", "/etc/nginx/conf.d"]

# 포트 지정
EXPOSE 80