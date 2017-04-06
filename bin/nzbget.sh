#!/usr/bin/env bash

set -e

# Install NZBGet.
if [[ ! -d /opt/var/nzbget ]]; then
	wget -nv -O - http://nzbget.net/info/nzbget-version-linux.json | \
		sed -n "s/^.*stable-download.*: \"\(.*\)\".*/\1/p" | \
		wget -nv --no-check-certificate -i - -O nzbget-latest-bin-linux.run
	sh nzbget-latest-bin-linux.run --destdir /opt/var/nzbget
	rm nzbget-latest-bin-linux.run
	rm /opt/var/nzbget/nzbget.conf
fi

# Create required directories.
mkdir -p /opt/var/couchpotatoserver
mkdir -p /opt/var/nzbToMedia

# Get nzbToMedia source code.
cd /opt/var/nzbToMedia
if [[ ! -d .git ]]; then
	git clone https://github.com/clinton-hall/nzbToMedia.git $PWD
fi

# Render config template.
cd /opt/var/nzbget
if [[ ! -f nzbget.conf ]]; then
	dockerize -template /opt/etc/nzbget.tmpl.conf:nzbget.conf
fi

exec /opt/var/nzbget/nzbget --configfile /opt/var/nzbget/nzbget.conf --server
