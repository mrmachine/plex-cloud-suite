#!/usr/bin/env bash

set -e

# Wait until Rclone and UnionFS storage are mounted.
wait-for-storage.sh

# Create required directories.
mkdir -p /mnt/local/process/Movies
mkdir -p /mnt/remote/storage/Movies
mkdir -p /opt/var/couchpotatoserver/src

# Get source code.
cd /opt/var/couchpotatoserver/src
if [[ ! -d .git ]]; then
	git clone https://github.com/CouchPotato/CouchPotatoServer.git $PWD
fi

# Render config template.
cd /opt/var/couchpotatoserver
if [[ ! -f settings.conf ]]; then
	dockerize -template /opt/etc/couchpotatoserver_settings.tmpl.conf:settings.conf
fi

exec python2 /opt/var/couchpotatoserver/src/CouchPotato.py --console_log --data_dir=/opt/var/couchpotatoserver
