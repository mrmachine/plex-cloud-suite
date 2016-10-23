#!/usr/bin/env bash

set -e

# Environment.
export LIVE_CERT_FOLDER="/etc/letsencrypt/live/plex.$DOMAIN"

# Create required directories.
mkdir -p /opt/var/ssl
mkdir -p /opt/www

# Create or renew certificate, every 12 hours.
while true; do
	if certbot certonly \
			--agree-tos \
			--domains "plex.$DOMAIN,couchpotato.$DOMAIN,nzbget.$DOMAIN,sickrage.$DOMAIN,transmission.$DOMAIN" \
			--email "$EMAIL" \
			--expand \
			--noninteractive \
			--webroot \
			--webroot-path /opt/www; then
		ln -fs "$LIVE_CERT_FOLDER/fullchain.pem" /opt/var/ssl/ca.pem
		ln -fs "$LIVE_CERT_FOLDER/privkey.pem" /opt/var/ssl/key.pem
		nginx -s reload
	fi
	echo "Sleeping for 43200 seconds (12 hours) before renewing SSL certificates."
	sleep 43200  # 12 hours
done
