#!/usr/bin/env bash

set -e

export SUPERVISORD_INCLUDE_FILES="${SUPERVISORD_INCLUDE_FILES:-couchpotatoserver.conf nzbget.conf sickrage.conf transmission.conf}"

if [[ -z "$@" ]]; then
	exec supervisord --configuration /opt/etc/supervisor/supervisord.conf
else
	exec supervisorctl --configuration /opt/etc/supervisor/supervisord.conf "$@"
fi
