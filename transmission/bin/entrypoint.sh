#!/bin/sh

set -e

cd /opt/transmission/var

# Get nzbToMedia source code.
if [[ ! -d /opt/transmission/var/nzbToMedia/.git ]]; then
	git clone https://github.com/clinton-hall/nzbToMedia.git /opt/transmission/var/nzbToMedia
else
	# Update source code.
	if [[ -z "$DISABLE_AUTOUPDATE" ]]
	then
		(cd /opt/transmission/var/nzbToMedia && git pull)
	fi
fi

# Default nzbToMedia config.
if [[ ! -f nzbToMedia/autoProcessMedia.cfg ]]; then
	# Fix category names in default config, so we only need to specify changes
	# in our template.
	sed -i 's/[[comics]]/[[Comics]]/' nzbToMedia/autoProcessMedia.cfg.spec
	sed -i 's/[[movie]]/[[Movies]]/' nzbToMedia/autoProcessMedia.cfg.spec
	sed -i 's/[[music]]/[[Music]]/' nzbToMedia/autoProcessMedia.cfg.spec
	dockerize -template ../autoProcessMedia.tmpl.cfg:nzbToMedia/autoProcessMedia.cfg
	# Undo changes to default config.
	(cd nzbToMedia && git checkout -- nzbToMedia/autoProcessMedia.cfg.spec)
fi

# Default Transmission config.
[[ ! -f settings.json ]] && cp ../settings.json .

exec "${@:-sh}"
