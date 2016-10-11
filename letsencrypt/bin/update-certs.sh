#!/bin/bash

set -e

mkdir -p /opt/www

# Certificates are separated by semi-colon (;). Domains on each certificate are
# separated by comma (,).
CERTS=(${DOMAINS//;/ })

# Create or renew certificates. Don't exit on error. It's likely that certbot
# will fail on first run, if HAproxy is not running.
for DOMAINS in "${CERTS[@]}"; do
	certbot certonly \
		--agree-tos \
		--domains "$DOMAINS" \
		--email "$EMAIL" \
		--expand \
		--noninteractive \
		--webroot \
		--webroot-path /opt/www \
		$OPTIONS || true
done
