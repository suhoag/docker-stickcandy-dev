#!/bin/bash

supervisord_conf="/etc/supervisor/supervisord.conf"

/usr/bin/supervisord -c ${supervisord_conf}
