#!/bin/sh

set -e

exec python /mnt/storage/Docker/couchpotatoserver/src/CouchPotato.py --console_log --data_dir=/mnt/storage/Docker/couchpotatoserver
