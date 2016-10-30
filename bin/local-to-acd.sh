#!/usr/bin/env bash

set -e

while true; do
	# Sleep until 3AM. See: http://stackoverflow.com/a/19067658
	SECONDS_UNTIL_3AM="$((($(date -f - +%s- <<<$'03:00 tomorrow\nnow')0)%86400))"
	echo "Sleeping for $SECONDS_UNTIL_3AM seconds (until 3AM) before moving local storage files to ACD storage."
	sleep "$SECONDS_UNTIL_3AM"

	echo 'Moving files from /mnt/local-storage to /mnt/acd-storage.'
	rsync -av --exclude 'Downloads' --remove-source-files /mnt/local-storage /mnt/acd-storage
done
