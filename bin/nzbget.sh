#!/usr/bin/env bash

set -e

# Create required directories
mkdir -p /opt/var/couchpotatoserver
mkdir -p /opt/var/nzbget
mkdir -p /opt/var/nzbget/dst
mkdir -p /opt/var/nzbToMedia

# Get source code.
cd /opt/var/nzbToMedia
if [[ ! -d .git ]]; then
	git clone https://github.com/clinton-hall/nzbToMedia.git $PWD
fi

# Render config template.
cd /opt/var/nzbget
if [[ ! -f nzbget.conf ]]; then
	dockerize -template /opt/etc/nzbget.tmpl.conf:nzbget.conf
fi

exec nzbget --configfile /opt/var/nzbget/nzbget.conf --server
