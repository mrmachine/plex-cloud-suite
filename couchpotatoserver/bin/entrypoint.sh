#!/bin/bash

set -e

# Create required directories.
mkdir -p /mnt/storage/Docker/couchpotatoserver/src
mkdir -p /mnt/storage/Downloads/Process/Movies
mkdir -p /mnt/storage/Movies

# Get source code.
cd /mnt/storage/Docker/couchpotatoserver/src
if [[ ! -d .git ]]; then
	git clone https://github.com/CouchPotato/CouchPotatoServer.git $PWD
else
	# Update source code.
	if [[ -z "$DISABLE_AUTOUPDATE" ]]; then
		git pull
	fi
fi

# Generate API key.
cd /mnt/storage/Docker/couchpotatoserver
if [[ ! -f api_key.txt ]]; then
	head /dev/urandom | md5sum | head -c 32 > api_key.txt
fi
export COUCHPOTATOSERVER_API_KEY="$(cat api_key.txt)"

# Render config template.
cd /mnt/storage/Docker/couchpotatoserver
if [[ ! -f settings.conf ]]; then
	dockerize -template /opt/couchpotatoserver/settings.tmpl.conf:settings.conf
fi

exec "${@:-bash}"
