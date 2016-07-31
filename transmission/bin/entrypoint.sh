#!/bin/sh

set -e

cd /opt/transmission/var

# Render config template.
if [[ ! -f settings.json ]]; then
	cp ../settings.json .
fi

exec "${@:-sh}"
