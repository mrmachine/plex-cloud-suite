#!/bin/bash

set -e

# Abort if run interactively.
if [[ -z "$TR_APP_VERSION" ]]; then
	exit 1
fi

cat <<EOF
Processing completed torrent:
  TR_APP_VERSION: $TR_APP_VERSION
  TR_TIME_LOCALTIME: $TR_TIME_LOCALTIME
  TR_TORRENT_DIR: $TR_TORRENT_DIR
  TR_TORRENT_HASH: $TR_TORRENT_HASH
  TR_TORRENT_ID: $TR_TORRENT_ID
  TR_TORRENT_NAME: $TR_TORRENT_NAME
EOF

# Get absolute path to torrent data.
TORRENT_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"

# Get Transmission download directory.
DOWNLOAD_DIR=$(jq -r '.["download-dir"]' /opt/transmission/var/settings.json)

# Get destination path. If torrent data is in a subdirectory of the
# Transmission download directory, recreate intermediate directories in the
# complete downloads directory.
if [[ "$TORRENT_PATH" == "$DOWNLOAD_DIR"* ]]; then
	# Strip the Transmission download directory prefix from the torrent path to
	# get a relative path.
	DST="/mnt/storage/Downloads/complete/${TORRENT_PATH#$DOWNLOAD_DIR}"
else
	# Fallback to torrent name in complete downloads directory.
	DST="/mnt/storage/Downloads/complete/$TR_TORRENT_NAME"
fi

cat <<EOF
  TORRENT_PATH: $TORRENT_PATH
  DOWNLOAD_DIR: $DOWNLOAD_DIR
  DST: $DST
EOF

# Hard link torrent data to the complete downloads directory.
hardlink "$TORRENT_PATH" "$DST"

# Remove torrents and data from Transmission when ratio or seeding time limit
# has been reached.
clean-transmission.sh
