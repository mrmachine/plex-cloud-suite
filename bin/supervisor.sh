#!/usr/bin/env bash

set -e

if [[ -z "$@" ]]; then
	exec supervisord --configuration /opt/etc/supervisor/supervisord.conf
else
	exec supervisorctl --configuration /opt/etc/supervisor/supervisord.conf "$@"
fi
