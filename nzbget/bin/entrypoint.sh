#!/bin/sh

set -e

cd /opt/nzbget/var

# Get nzbToMedia source code.
if [[ ! -d /opt/nzbget/var/nzbToMedia ]]; then
	git clone https://github.com/clinton-hall/nzbToMedia.git /opt/nzbget/var/nzbToMedia
else
	# Update source code.
	if [[ -z "$DISABLE_AUTOUPDATE" ]]
	then
		(cd /opt/nzbget/var/nzbToMedia && git pull)
	fi
fi

# Render config template.
if [[ ! -f nzbget.conf ]]; then
	dockerize -template ../nzbget.tmpl.conf:nzbget.conf
fi

exec "${@:-sh}"
