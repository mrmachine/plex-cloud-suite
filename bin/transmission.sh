#!/usr/bin/env bash

set -e

# Create required directories.
mkdir -p /opt/var/transmission

# Render config template.
cd /opt/var/transmission
if [[ ! -f settings.json ]]; then
	cp /opt/etc/transmission_settings.json .
fi

exec transmission-daemon --config-dir /opt/var/transmission --foreground
