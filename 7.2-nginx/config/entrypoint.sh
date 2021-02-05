#!/bin/bash

set -e

/usr/sbin/php-fpm$PHP_VERSION -F -R --pid /run/php-fpm.pid &

nginx

fg %1

exec "$@"