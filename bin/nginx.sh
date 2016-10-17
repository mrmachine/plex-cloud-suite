#!/usr/bin/env bash

set -e

mkdir -p /opt/var/ssl
cd /opt/var/ssl

# Create a self signed default certificate, so nginx can start before we have
# a real certificate.
if [[ ! -f ca.pem || ! -f key.pem ]]; then
	openssl req -x509 -newkey rsa:2048 -keyout key.pem -out ca.pem -days 90 -nodes -subj "/CN=*/O=Plex Cloud EncFS/C=US"
fi

exec nginx -c "/opt/etc/nginx.conf" -g "worker_processes auto;" "$@"
