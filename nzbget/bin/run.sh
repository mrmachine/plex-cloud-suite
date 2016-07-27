#!/bin/sh

set -e

exec nzbget --configfile /opt/nzbget/var/nzbget.conf --server
