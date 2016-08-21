#!/bin/sh

set -e

# Create required directories.
mkdir -p /mnt/storage/Docker/transmission

# Render config template.
cd /mnt/storage/Docker/transmission
if [[ ! -f settings.json ]]; then
	cp /opt/transmission/settings.json .
fi

exec "${@:-sh}"
