#!/usr/bin/env bash

set -e

mkdir -p /opt/var/ssl
cd /opt/var/ssl

# Create a self signed default certificate, so nginx can start before we have
# a real certificate.
if [[ ! -s ca.pem || ! -s key.pem ]]; then
	rm -f ca.pem key.pem
	openssl req -x509 -newkey rsa:2048 -keyout key.pem -out ca.pem -days 90 -nodes -subj "/CN=*/O=Plex Cloud Suite/C=US"
fi

exec nginx -c "/opt/etc/nginx.conf" -g "worker_processes auto;" "$@"
