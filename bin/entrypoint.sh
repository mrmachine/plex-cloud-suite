#!/usr/bin/env bash

set -e

# Fail loudly when required environment variables are missing.
for var in BASIC_AUTH_PASSWORD BASIC_AUTH_USERNAME DOMAIN EMAIL ENCFS_PASSWORD PLEX_PASSWORD PLEX_USERNAME; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Required environment variable is missing: $var"
		exit 1
	}
done

# Environment.
export ACD_CLI_CACHE_PATH=/opt/var/acd_cli
export ACD_STORAGE_DIR="${ACD_STORAGE_DIR:-PCE}"  # Relative to ACD root
export ENCFS6_CONFIG=/opt/var/encfs.xml

# Wait while user does setup in another interactive shell, if necessary.
if [[ ! -t 0 ]]; then
	cat <<-EOF

	Amazon Cloud Drive authentication data or EncFS config file not found.
	You need to run 'entrypoint.sh' interactively to configure.

	On Docker Cloud, open a web terminal and run:

		# entrypoint.sh

	Locally, run:

		$ docker exec -it $(hostname) entrypoint.sh

	Waiting. Press CTRL-C to abort.

	EOF

	while [[ ! -f "$ENCFS6_CONFIG" || ! -f "$ACD_CLI_CACHE_PATH/oauth_data" ]]; do
		sleep 1
		echo -n '.'
	done

	echo 'Done!'
fi

# Create directories for mount points.
mkdir -p /mnt/acd
mkdir -p /mnt/acd-storage
mkdir -p /mnt/local-storage

# Mount Amazon Cloud Drive.
acd_cli sync
if [[ -z "$(mount | grep /mnt/acd)" ]]; then
	acd_cli mount /mnt/acd
fi

# Mount EncFS filesystem.
if [[ -z "$(mount | grep /mnt/acd-storage)" ]]; then
	encfs --extpass=extpass.sh "/mnt/acd/$ACD_STORAGE_DIR" /mnt/acd-storage
fi

# Create other required directories.
mkdir -p /mnt/acd-storage/'Home Videos'
mkdir -p /mnt/acd-storage/Movies
mkdir -p /mnt/acd-storage/Music
mkdir -p /mnt/acd-storage/Photos
mkdir -p /mnt/acd-storage/'TV Shows'
mkdir -p /opt/var/couchpotatoserver
mkdir -p /opt/var/sickrage

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
