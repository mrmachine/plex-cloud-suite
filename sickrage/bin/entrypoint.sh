#!/bin/bash

set -e

# Create required directories.
mkdir -p "/mnt/storage/Downloads/Process/TV Shows"
mkdir -p "/mnt/storage/TV Shows"
mkdir -p /mnt/storage/Docker/sickrage/src

# Get source code.
cd /mnt/storage/Docker/sickrage/src
if [[ ! -d .git ]]; then
	git clone https://github.com/SickRage/SickRage.git $PWD
else
	# Update source code.
	if [[ -z "$DISABLE_AUTOUPDATE" ]]; then
		git pull
	fi
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
export PATH="/mnt/storage/Docker/sickrage/venv/bin:$PATH"
export PIP_SRC=/mnt/storage/Docker/sickrage/venv/src
export PYTHONUSERBASE=/mnt/storage/Docker/sickrage/venv

# Install Python packages.
cd /mnt/storage/Docker/sickrage
if [[ ! -f venv.md5 ]] || ! md5sum -c -s venv.md5; then
	pip install -e src
	md5sum src/setup.py > venv.md5
fi

# Generate API key.
cd /mnt/storage/Docker/sickrage
if [[ ! -f api_key.txt ]]; then
	head /dev/urandom | md5sum | head -c 32 > api_key.txt
fi
export SICKRAGE_API_KEY="$(cat api_key.txt)"

# Render config template.
cd /mnt/storage/Docker/sickrage
if [[ ! -f config.ini ]]; then
	dockerize -template /opt/sickrage/config.tmpl.ini:config.ini
fi

exec "${@:-bash}"
