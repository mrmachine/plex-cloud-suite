#!/bin/bash

set -e

cd /opt/couchpotatoserver/src

# Get source code.
if [[ ! -d .git ]]; then
	git clone https://github.com/CouchPotato/CouchPotatoServer.git .
else
	# Update source code.
	if [[ -z "$DISABLE_AUTOUPDATE" ]]; then
		git pull
	fi
fi

# Generate random API key.
if [[ ! -f ../var/couchpotatoserver_api_key.txt ]]; then
	head /dev/urandom | md5sum | head -c 32 > ../var/couchpotatoserver_api_key.txt
fi
export COUCHPOTATOSERVER_API_KEY="$(cat ../var/couchpotatoserver_api_key.txt)"

# Render config template.
if [[ ! -f ../var/settings.conf ]]; then
	dockerize -template ../settings.tmpl.conf:../var/settings.conf
fi

# Create required directories.
mkdir -p /mnt/storage/Downloads/complete/Movies

exec "${@:-bash}"
