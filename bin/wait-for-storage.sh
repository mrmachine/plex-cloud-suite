#!/usr/bin/env bash

set -e

while ! (mount | grep -q fuse.rclone); do
	echo 'Rclone storage not mounted. Sleeping for 1 second.'
	sleep 1
done

while ! (mount | grep -q fuse.unionfs); do
	echo 'UnionFS storage not mounted. Sleeping for 1 second.'
	sleep 1
done

exec "$@"
