#!/bin/sh

set -e

cd /opt/nzbget/var

# Render config template.
if [[ ! -f nzbget.conf ]]; then
	dockerize -template ../nzbget.tmpl.conf:nzbget.conf
fi

exec "${@:-sh}"
