#!/usr/bin/env bash

set -e

if ! (mount | grep -q fuse.rclone); then
	# Get config from environment.
	mkdir -p /root/.config/rclone
	echo "$RCLONE_CONF" > /root/.config/rclone/rclone.conf

	# Create mount point.
	mkdir -p /mnt/storage

	# Unmount on exit.
	trap 'fusermount -quz /mnt/storage' INT TERM EXIT

	# Mount.
	rclone mount \
		--stats 1s \
		-v \
		remote: /mnt/storage
fi
