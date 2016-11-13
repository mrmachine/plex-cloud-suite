#!/usr/bin/env bash

set -e

cat <<EOF
You are running an interactive BASH shell. Here is a list of commands you might
want to run:

	bash.sh
	clean-transmission.sh
	couchpotatoserver.sh
	entrypoint.sh
	extpass.sh
	letsencrypt.sh
	nginx.sh
	nzbget.sh
	plexmediaserver.sh
	sickrage.sh
	supervisor.sh
	torrent-done.sh
	transmission.sh

For more info on each command, run:

    help.sh

EOF

exec bash --norc --noprofile
