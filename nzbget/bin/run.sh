#!/bin/sh

set -e

exec nzbget \
	--configfile /opt/nzbget/var/nzbget.conf \
	--option ControlIP=0.0.0.0 \
	--option OutputMode=loggable \
	--server
