#!/bin/bash

# Remove torrents and data from Transmission when ratio or seeding time
# requirements have been satisfied.

set -e

# {category:ratio:hours};...
REQUIREMENTS="${REQUIREMENTS:-Movies:2.0:;TV Shows::240}"
IFS=';' read -r -a REQUIREMENTS <<< "$REQUIREMENTS"

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
Clean Torrent:
  NAME: $NAME
  LOCATION: $LOCATION
  PERCENT DONE: $PERCENT_DONE
  RATIO: $RATIO
  SEEDING TIME: $SEEDING_TIME
EOF

    # Skip if incomplete.
    if [[ "$PERCENT_DONE" != 100 ]]; then
        echo '  Torrent is incomplete. Do nothing.'
        continue
    fi

    # Check requirements for category matching torrent location.
    for CATEGORY in "${REQUIREMENTS[@]}";
    do
        IFS=':' read category ratio_req seeding_time_req <<< "$CATEGORY"

        # Skip if category doesn't match torrent location.
        if [[ "$category" != "$LOCATION" ]]; then
            continue
        fi

        cat <<EOF
  Requirements:
    RATIO: $ratio_req
    SEEDING TIME: $seeding_time_req
EOF

        # Remove and delete if ratio or seeding time requiement satisfied.
        if [[ -n "$ratio_req" && $(echo "$RATIO >= $ratio_req" | bc) = 1 ]] || \
           [[ -n "$seeding_time_req" && $(echo "$SEEDING_TIME >= $seeding_time_req" | bc) = 1 ]]
        then
            echo "  Requirements satisfied. Remove and delete torrent: $NAME"
            transmission-remote --torrent $ID --remove-and-delete
        else
            echo '  Requirements not satisfied. Do nothing.'
        fi
    done
done
