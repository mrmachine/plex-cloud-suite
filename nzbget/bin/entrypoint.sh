#!/bin/sh

set -e

cd /opt/nzbget/var

# Default config.
if [[ ! -f nzbget.conf ]]; then
	cp /usr/share/nzbget/nzbget.conf .
	sed -i -e "s#\(MainDir=\).*#\1/mnt/storage/NZBGet#g" nzbget.conf
	sed -i -e "s#\(ControlPassword=\).*#\1#g" nzbget.conf
fi

exec "${@:-sh}"
