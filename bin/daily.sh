#!/usr/bin/env bash

set -e

# Do daily maintenance at startup.
letsencrypt.sh
rsync-local-storage-to-acd.sh

while true; do
	# Sleep until 3AM. See: http://stackoverflow.com/a/19067658
	SECONDS_UNTIL_3AM="$((($(date -f - +%s- <<<$'03:00 tomorrow\nnow')0)%86400))"
	echo "Sleeping for $SECONDS_UNTIL_3AM seconds (until 3AM)."
	sleep "$SECONDS_UNTIL_3AM"

	# Do daily maintenance at 3AM.
	letsencrypt.sh
	rsync-local-storage-to-acd.sh
done
