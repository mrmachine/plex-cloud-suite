#!/bin/bash

set -e

cd /opt/sickrage/src

# Get source code.
if [[ ! -d .git ]]; then
	git clone https://github.com/SickRage/SickRage.git .
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
export PATH="$PWD/venv/bin:$PATH"
export PIP_SRC="$PWD/venv/src"
export PYTHONUSERBASE="$PWD/venv"

# Install Python packages.
if [[ ! -f venv.md5 ]] || ! md5sum -c -s venv.md5; then
	pip install -e .
	md5sum setup.py > venv.md5
fi

# Generate random API key.
if [[ ! -f ../var/sickrage_api_key.txt ]]; then
	head /dev/urandom | md5sum | head -c 32 > ../var/sickrage_api_key.txt
fi
export SICKRAGE_API_KEY="$(cat ../var/sickrage_api_key.txt)"

# Render config template.
if [[ ! -f ../var/config.ini ]]; then
	dockerize -template ../config.tmpl.ini:../var/config.ini
fi

# Create required directories.
mkdir -p "/mnt/storage/Downloads/complete/TV Shows"

exec "${@:-bash}"
