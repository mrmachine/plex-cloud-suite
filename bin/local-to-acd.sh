#!/usr/bin/env bash

set -e

while true; do
	# Sleep until 3AM. See: http://stackoverflow.com/a/19067658
	SECONDS_UNTIL_3AM="$((($(date -f - +%s- <<<$'03:00 tomorrow\nnow')0)%86400))"
	echo "Sleeping for $SECONDS_UNTIL_3AM seconds (until 3AM) before moving local storage files to ACD storage"
	sleep "$SECONDS_UNTIL_3AM"

	# Sleep with exponential backoff while there are open files in local storage.
	BACKOFF=1
	SECONDS=0
	while true; do
		FILES=$(lsof /mnt/local-storage)
		# No open files. Continue.
		if [[ -z "$FILES" ]]; then
			echo 'Moving files from /mnt/local-storage to /mnt/acd-storage'
			rsync -av --exclude 'Downloads' --remove-source-files /mnt/local-storage /mnt/acd-storage
			break
		fi
		# Next backoff will take us past 24 hours. Abort.
		if ((BACKOFF + SECONDS >= 86400)); then
			>&2 cat <<-EOF
			Unable to move open files from local storage to ACD storage:
			$FILES
			EOF
			break
		fi
		# Sleep for exponential backoff.
		sleep "$BACKOFF"
		((BACKOFF = BACKOFF * 2))
	done
done
