#!/bin/sh

set -e

cd /opt/transmission/var

# Default config.
if [[ ! -f settings.json ]]; then
	cp ../settings.json .
fi

exec "${@:-sh}"
