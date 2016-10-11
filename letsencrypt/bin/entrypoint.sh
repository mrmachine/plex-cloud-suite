#!/bin/bash

set -e

for var in DOMAINS EMAIL; do
    eval [[ -z \${$var+1} ]] && {
        >&2 echo "ERROR: Missing environment variable: $var"
        exit 1
    }
done

# Get number of CPU cores, so we know how many processes to run.
export CPU_CORES=$(python -c 'import multiprocessing; print multiprocessing.cpu_count();')

exec "$@"
