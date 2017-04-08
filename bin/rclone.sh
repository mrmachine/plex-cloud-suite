#!/usr/bin/env bash

set -e

# Get config from environment.
mkdir -p /root/.config/rclone
echo "$RCLONE_CONF" > /root/.config/rclone/rclone.conf

# Create mount point.
mkdir -p /mnt/storage

# Mount Rclone remote.
rclone mount \
	--stats 1s \
	-v \
	remote: /mnt/storage
