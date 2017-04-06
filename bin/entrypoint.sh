#!/usr/bin/env bash

set -e

# Fail loudly when required environment variables are missing.
for var in BASIC_AUTH_PASSWORD BASIC_AUTH_USERNAME DOMAIN EMAIL ENCFS_PASSWORD GOOGLE_APPLICATION_CREDENTIALS PLEX_PASSWORD PLEX_USERNAME; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Required environment variable is missing: $var"
		exit 1
	}
done

# Environment.
export PCE_STORAGE_DIR="${PCE_STORAGE_DIR:-PCE}"  # Relative to ACD root

# Create required local directories.
mkdir -p /mnt/gcp
mkdir -p /mnt/local-storage
mkdir -p /mnt/storage
mkdir -p /opt/var/couchpotatoserver
mkdir -p /opt/var/sickrage

# Get Google Cloud Platform credentials from environment.
echo "$GOOGLE_APPLICATION_CREDENTIALS" > /opt/var/key.json
export GOOGLE_APPLICATION_CREDENTIALS=/opt/var/key.json

# Mount Google Cloud Storage bucket.
gcsfuse "$GOOGLE_CLOUD_STORAGE_BUCKET" /mnt/gcp

# Create storage directory to avoid interactive prompt.
mkdir -p "/mnt/gcp/$PCE_STORAGE_DIR"

if [[ ! -f "/mnt/gcp/$PCE_STORAGE_DIR/.encfs6.xml" ]]; then
	# Create and mount EncFS filesystem, with pre-configured paranoia mode.
	echo p | encfs --extpass=extpass.sh "/mnt/gcp/$PCE_STORAGE_DIR" /mnt/storage
elif [[ -z "$(mount | grep /mnt/storage)" ]]; then
	# Mount EncFS filesystem.
	encfs --extpass=extpass.sh "/mnt/gcp/$PCE_STORAGE_DIR" /mnt/storage
fi

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
