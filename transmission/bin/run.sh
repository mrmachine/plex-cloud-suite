#!/bin/sh

set -e

exec transmission-daemon --config-dir /opt/transmission/var --foreground
