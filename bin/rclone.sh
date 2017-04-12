#!/usr/bin/env bash

set -e

# Unmount on exit.
trap 'fusermount -quz /mnt/storage; fusermount -quz /mnt/remote/storage' INT TERM EXIT

while true; do

	# Mount Rclone storage.
	if ! (mount | grep -q fuse.rclone); then
		# Get config from environment.
		mkdir -p /root/.config/rclone
		echo "$RCLONE_CONF" > /root/.config/rclone/rclone.conf

		# Create mount point.
		mkdir -p /mnt/remote/storage

		# Mount.
		rclone mount \
			--read-only \
			--stats 5s \
			--verbose \
			remote: \
			/mnt/remote/storage &
	fi

	# Mount UnionFS storage.
	if ! (mount | grep -q fuse.unionfs); then
		# Create mount point.
		mkdir -p /mnt/remote/storage

		# Mount.
		unionfs-fuse \
			-o cow \
			/mnt/local/storage=RW:/mnt/remote/storage=RW \
			/mnt/storage
	fi

	# Move local storage to remote.
	rclone move \
		--exclude=.unionfs/** \
		--min-age=1m \
		--no-traverse \
		--verbose \
		/mnt/local/storage/ \
		remote:

	# Clean up empty directories left by Rclone move.
	find /mnt/local/storage/ -type d -empty -delete

	# Wait at least 1 minute between iterations.
	sleep 60
done
