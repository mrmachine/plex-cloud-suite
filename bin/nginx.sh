#!/usr/bin/env bash

set -e

# Create a self signed default certificate, so nginx can start before we have
# a real certificate.
if [[ ! -f /opt/var/ssl/ca.pem || ! -f /opt/var/ssl/key.pem ]]; then
	mkdir -p /opt/var/ssl
	openssl req -x509 -newkey rsa:2048 -keyout key.pem -out ca.pem -days 90 -nodes -subj "/CN=*/O=Plex Cloud EncFS/C=US"
fi

exec nginx -c "/opt/etc/nginx.conf" -g "worker_processes auto;" "$@"
