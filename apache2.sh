#!/bin/sh
# Apache service startup script
source /etc/apache2/envvars 
# Process must not be detached
exec /usr/sbin/apache2ctl -DFOREGROUND >> /var/log/apache2.log 2>&1

