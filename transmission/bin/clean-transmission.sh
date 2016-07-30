#!/bin/bash

# Remove torrents and data from Transmission when ratio or seeding time limit
# has been reached.

set -e

# {category:ratio:hours};...
CATEGORY_LIMITS="${CATEGORY_LIMITS:-Movies:2.0:;TV Shows::240}"
IFS=';' read -r -a CATEGORY_LIMITS <<< "$CATEGORY_LIMITS"

# Use sed to get list of torrent IDs.
for ID in $(transmission-remote --list | sed -nr 's/^ *(\d+).*/\1/p')
do
    # Use sed to get torrent info.
    NAME=$(transmission-remote --torrent $ID --info | sed -nr 's/.*Name: (.+)/\1/p')
    LOCATION=$(transmission-remote --torrent $ID --info | sed -nr 's/.*Location:.*[/](.+)/\1/p')
    PERCENT_DONE=$(transmission-remote --torrent $ID --info | sed -nr 's/.*Percent Done: (\d+).*/\1/p')
    RATIO=$(transmission-remote --torrent $ID --info | sed -nr 's/.*Ratio: ([.0-9]+)/\1/p')
    SEEDING_TIME=$(transmission-remote --torrent $ID --info | sed -nr 's/.*Seeding Time:.*[(](\d+).*/\1/p')

    # Convert seconds to hours.
    SEEDING_TIME=$(echo "${SEEDING_TIME:-0} / 60 / 60" | bc)

    cat <<EOF
Cleaning Torrent
  NAME: $NAME
  LOCATION: $LOCATION
  PERCENT DONE: $PERCENT_DONE
  RATIO: $RATIO
  SEEDING TIME: $SEEDING_TIME
EOF

    # Skip if incomplete.
    if [[ "$PERCENT_DONE" != 100 ]]; then
        echo '  # Do nothing. Torrent is incomplete.'
        continue
    fi

    # Check limits for matching category.
    for LIMITS in "${CATEGORY_LIMITS[@]}";
    do
        IFS=':' read category ratio_limit seeding_time_limit <<< "$LIMITS"

        # Skip if category doesn't match location.
        if [[ "$category" != "$LOCATION" ]]; then
            continue
        fi

        cat <<EOF
  Limits
    RATIO: $ratio_limit
    SEEDING TIME: $seeding_time_limit
EOF

        # Remove and delete if ratio or seeding time limit reached.
        if [[ -n "$ratio_limit" && $(echo "$RATIO >= $ratio_limit" | bc) = 1 ]] || \
           [[ -n "$seeding_time_limit" && $(echo "$SEEDING_TIME >= $seeding_time_limit" | bc) = 1 ]]
        then
            echo "  # Remove and delete torrent: $NAME"
            transmission-remote --torrent $ID --remove-and-delete
        else
            echo '  # Do nothing. Limits not reached.'
        fi
    done
done
