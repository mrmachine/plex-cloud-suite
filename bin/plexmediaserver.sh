#!/usr/bin/env bash

set -e

if [[ ! -f "/opt/var/plexmediaserver/Preferences.xml" ]]; then
	# Get authentication token.
	if [[ -z "$PLEX_TOKEN" ]]; then
		export PLEX_TOKEN=$(curl -s -u "$PLEX_USERNAME:$PLEX_PASSWORD" https://plex.tv/users/sign_in.xml \
			-X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
			-H 'X-Plex-Provides: server' \
			-H 'X-Plex-Version: 0.9' \
			-H 'X-Plex-Platform-Version: 0.9' \
			-H 'X-Plex-Platform: xcid' \
			-H 'X-Plex-Product: Plex Media Server'\
			-H 'X-Plex-Device: Linux'\
			-H 'X-Plex-Client-Identifier: XXXX' --compressed | sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p')
	fi
	if [[ -z "$PLEX_TOKEN" ]]; then
		>&2 echo 'Unable to authenticate. Required environment variable is empty: PLEX_TOKEN'
		exit 1
	fi
	# Render preferences template.
	mkdir -p "/opt/var/plexmediaserver"
	dockerize -template "/opt/etc/plexmediaserver_Preferences.tmpl.xml:/opt/var/plexmediaserver/Preferences.xml"
fi

mkdir -p "$HOME/Library/Application Support"
ln -fs /opt/var/plexmediaserver "/root/Library/Application Support/Plex Media Server"

exec start_pms
