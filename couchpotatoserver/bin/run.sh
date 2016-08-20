#!/bin/sh

set -e

exec python /opt/couchpotatoserver/src/CouchPotato.py --console_log --data_dir=/opt/couchpotatoserver/var
