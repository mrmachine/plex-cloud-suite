#!/usr/bin/env bash

set -e

# Render config template.
if [[ ! -f /opt/etc/logentries.conf ]]; then
	dockerize -template /opt/etc/logentries.tmpl.conf:/opt/etc/logentries.conf
fi

exec le monitor --config=/opt/etc/logentries.conf
