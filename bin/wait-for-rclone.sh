#!/usr/bin/env bash

set -e

while ! (mount | grep -q fuse.rclone); do
	echo 'Rclone remote not mounted. Sleeping for 1 second.'
	sleep 1
done

exec "$@"
