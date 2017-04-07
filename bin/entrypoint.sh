#!/usr/bin/env bash

set -e

# Fail loudly when required environment variables are missing.
for var in BASIC_AUTH_PASSWORD BASIC_AUTH_USERNAME DOMAIN EMAIL PLEX_PASSWORD PLEX_USERNAME RCLONE_CONF; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Required environment variable is missing: $var"
		exit 1
	}
done

# Create required local directories.
mkdir -p /mnt/local-storage
mkdir -p /mnt/storage
mkdir -p /opt/var/couchpotatoserver
mkdir -p /opt/var/sickrage
mkdir -p /root/.config/rclone

# Get Rclone config from environment.
echo "$RCLONE_CONF" > /root/.config/rclone/rclone.conf

# Mount Rclone remote.
rclone mount \
	--acd-templink-threshold 0 \
	--allow-other \
	--log-file="/opt/var/rclone.log" \
	--stats 1s \
	-v \
	remote: /mnt/storage &

# Create media library directories.
mkdir -p /mnt/storage/'Home Videos'
mkdir -p /mnt/storage/Movies
mkdir -p /mnt/storage/Music
mkdir -p /mnt/storage/Photos
mkdir -p /mnt/storage/'TV Shows'

# Generate CouchPotatoServer API key.
if [[ ! -f /opt/var/couchpotatoserver/api_key.txt ]]; then
	head /dev/urandom | md5sum | head -c 32 > /opt/var/couchpotatoserver/api_key.txt
fi
export COUCHPOTATOSERVER_API_KEY="$(cat /opt/var/couchpotatoserver/api_key.txt)"

# Generate SickRage API key.
if [[ ! -f /opt/var/sickrage/api_key.txt ]]; then
	head /dev/urandom | md5sum | head -c 32 > /opt/var/sickrage/api_key.txt
fi
export SICKRAGE_API_KEY="$(cat /opt/var/sickrage/api_key.txt)"

# Set basic auth credentials.
htpasswd -bc /opt/var/htpasswd "$BASIC_AUTH_USERNAME" "$BASIC_AUTH_PASSWORD"

exec "${@:-bash.sh}"
