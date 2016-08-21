#!/bin/sh

set -e

# Create required directories
mkdir -p /mnt/storage/Docker/couchpotatoserver
mkdir -p /mnt/storage/Docker/nzbget
mkdir -p /mnt/storage/Docker/nzbToMedia

# Get source code.
cd /mnt/storage/Docker/nzbToMedia
if [[ ! -d .git ]]; then
	git clone https://github.com/clinton-hall/nzbToMedia.git $PWD
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
cd /mnt/storage/Docker/nzbget
if [[ ! -f nzbget.conf ]]; then
	dockerize -template /opt/nzbget/nzbget.tmpl.conf:nzbget.conf
fi

exec "${@:-sh}"
