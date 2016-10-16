#!/bin/bash

set -e

mkdir -p /run/nginx

exec nginx -c "/opt/letsencrypt/etc/nginx.conf" -g "worker_processes auto;" "$@"
