#!/usr/bin/env bash

set -e

# Create required directories.
mkdir -p "/mnt/storage/Downloads/Process/TV Shows"
mkdir -p "/mnt/storage/TV Shows"
mkdir -p /opt/var/sickrage/src

# Get source code.
cd /opt/var/sickrage/src
if [[ ! -d .git ]]; then
	git clone https://github.com/SickRage/SickRage.git $PWD
fi

# Configure alternate location (user scheme) for Python packages.
pip() {
	if [[ "$1" = 'install' ]]; then
		shift
		set -- install --user "$@"
	fi
	command pip "$@"
}
export -f pip
export PATH="/opt/var/sickrage/venv/bin:$PATH"
export PIP_SRC=/opt/var/sickrage/venv/src
export PYTHONUSERBASE=/opt/var/sickrage/venv

# Install Python packages.
cd /opt/var/sickrage
if [[ ! -f venv.md5 ]] || ! md5sum --check --status venv.md5; then
	pip install -e src
	md5sum src/setup.py > venv.md5
fi

# Render config template.
cd /opt/var/sickrage
if [[ ! -f config.ini ]]; then
	dockerize -template /opt/etc/sickrage_config.tmpl.ini:config.ini
fi

exec python2 /opt/var/sickrage/src/SickBeard.py --datadir=/opt/var/sickrage
