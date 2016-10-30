#!/usr/bin/env bash

set -e

# Fail loudly when required environment variables are missing.
for var in ACD_OAUTH_DATA BASIC_AUTH_PASSWORD BASIC_AUTH_USERNAME DOMAIN EMAIL ENCFS_PASSWORD PLEX_PASSWORD PLEX_USERNAME; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Required environment variable is missing: $var"
		exit 1
	}
done

# Environment.
export ACD_CLI_CACHE_PATH=/opt/var/acd_cli
export ACD_STORAGE_DIR="${ACD_STORAGE_DIR:-PCE}"  # Relative to ACD root

# Create required local directories.
mkdir -p "$ACD_CLI_CACHE_PATH"
mkdir -p /mnt/acd
mkdir -p /mnt/acd-storage
mkdir -p /mnt/local-storage
mkdir -p /mnt/local-storage/'Home Videos'
mkdir -p /mnt/local-storage/Movies
mkdir -p /mnt/local-storage/Music
mkdir -p /mnt/local-storage/Photos
mkdir -p /mnt/local-storage/'TV Shows'
mkdir -p /mnt/storage
mkdir -p /opt/var/couchpotatoserver
mkdir -p /opt/var/sickrage

# Get Amazon Cloud Drive authentication data from environment.
echo "$ACD_OAUTH_DATA" > "$ACD_CLI_CACHE_PATH/oauth_data"

# Mount Amazon Cloud Drive.
acd_cli sync
if [[ -z "$(mount | grep /mnt/acd)" ]]; then
	acd_cli mount /mnt/acd
fi

# Create storage directory to avoid interactive prompt.
mkdir -p "/mnt/acd/$ACD_STORAGE_DIR"

# Create and mount EncFS filesystem, with pre-configured paranoia mode.
if [[ ! -f "/mnt/acd/$ACD_STORAGE_DIR/.encfs6.xml" ]]; then
	echo p | encfs --extpass=extpass.sh "/mnt/acd/$ACD_STORAGE_DIR" /mnt/acd-storage

# Mount EncFS filesystem.
elif [[ -z "$(mount | grep /mnt/acd-storage)" ]]; then
	encfs --extpass=extpass.sh "/mnt/acd/$ACD_STORAGE_DIR" /mnt/acd-storage
fi

# Mount UnionFS filesystem.
if [[ -z "$(mount | grep /mnt/storage)" ]]; then
	unionfs-fuse -o cow /mnt/local-storage=RW:/mnt/acd-storage=RW /mnt/storage
fi

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
