#!/bin/sh

set -e

exec nzbget --configfile /mnt/storage/Docker/nzbget/nzbget.conf --server
