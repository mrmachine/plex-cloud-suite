#!/bin/sh

# Recursively hard link completed torrent data to the complete downloads
# directory, so CouchPotato and SickRage can move them during post-processing
# without affecting torrents that are still being seeded.

set -e

# TR_APP_VERSION
# TR_TIME_LOCALTIME
# TR_TORRENT_DIR
# TR_TORRENT_HASH
# TR_TORRENT_ID
# TR_TORRENT_NAME

# Absolute path to torrent data.
TR_TORRENT_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"

# Strip the Transmission download directory prefix from the torrent path to get
# a relative path that we can recreate in the complete downloads directory.
TR_DOWNLOAD_DIR=$(jq -r '.download-dir' /opt/transmission/var/settings.json)
DST="/mnt/storage/Downloads/complete/${TR_TORRENT_PATH#$TR_DOWNLOAD_DIR}"

cat <<EOF
Processing completed torrent.
TR_APP_VERSION: $TR_APP_VERSION
TR_TIME_LOCALTIME: $TR_TIME_LOCALTIME
TR_TORRENT_DIR: $TR_TORRENT_DIR
TR_TORRENT_HASH: $TR_TORRENT_HASH
TR_TORRENT_ID: $TR_TORRENT_ID
TR_TORRENT_NAME: $TR_TORRENT_NAME
TR_TORRENT_PATH: $TR_TORRENT_PATH
TR_DOWNLOAD_DIR: $TR_DOWNLOAD_DIR
DST: $DST
EOF

# TODO: Handle cases where TR_TORRENT_DIR is not a subdirectory of
# TR_DOWNLOAD_DIR?

# Hard link torrent data to the complete downloads directory.
cp -lR "$TR_TORRENT_PATH" "$DST"
