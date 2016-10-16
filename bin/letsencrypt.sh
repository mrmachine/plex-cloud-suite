#!/usr/bin/env bash

# See: https://github.com/tartley/rerun2

set -e

# Environment.
export LIVE_CERT_FOLDER="/etc/letsencrypt/live/$DOMAIN"

# Create required directories.
mkdir -p "$LIVE_CERT_FOLDER"
mkdir -p /opt/var/ssl

# Debounce for 60 seconds, which we assume is enough time to create or renew
# all certifies and avoid multiple restarts.
IGNORE_SECS=60
IGNORE_UNTIL="$(date +%s)"

# Watch the live certificates directory. When changes are detected, link the
# certificate and reload nginx.
echo "Watching directory: $LIVE_CERT_FOLDER"
inotifywait \
	--event create \
	--event delete \
	--event modify \
	--event move \
	--format "%e %w%f" \
	--monitor \
	--quiet \
	--recursive \
	"$LIVE_CERT_FOLDER" |
while read CHANGED
do
	echo "$CHANGED"
	NOW="$(date +%s)"
	if (( NOW > IGNORE_UNTIL )); then
		(( IGNORE_UNTIL = NOW + IGNORE_SECS ))
		({
			sleep $IGNORE_SECS
			ln -fs "$LIVE_CERT_FOLDER/fullchain.pem" /opt/var/ssl/ca.pem
			ln -fs "$LIVE_CERT_FOLDER/privkey.pem" /opt/var/ssl/key.pem
			nginx -s reload
		}) &
	fi
done
