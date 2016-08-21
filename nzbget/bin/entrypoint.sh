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

# Render config template.
cd /mnt/storage/Docker/nzbget
if [[ ! -f nzbget.conf ]]; then
	dockerize -template /opt/nzbget/nzbget.tmpl.conf:nzbget.conf
fi

exec "${@:-sh}"
