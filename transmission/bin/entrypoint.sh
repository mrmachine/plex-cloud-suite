#!/bin/sh

set -e

cd /opt/transmission/var

# Default config.
[[ ! -f config.yml ]] && dockerize -template ../config.tmlp.yml:config.yml
[[ ! -f settings.json ]] && cp ../settings.json .

exec "${@:-sh}"
