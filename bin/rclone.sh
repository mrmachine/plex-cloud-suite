#!/usr/bin/env bash

set -e

# Get config from environment.
mkdir -p /root/.config/rclone
echo "$RCLONE_CONF" > /root/.config/rclone/rclone.conf

# Create mount point.
mkdir -p /mnt/storage

# Unmount before re-mounting.
if ! (mount | grep -q fuse.rclone); then
	fusermount -uz /mnt/storage
fi

# Mount.
rclone mount \
	--stats 1s \
	-v \
	remote: /mnt/storage
