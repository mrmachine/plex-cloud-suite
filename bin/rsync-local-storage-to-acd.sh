#!/usr/bin/env bash

set -e

echo 'Moving files from /mnt/local-storage to /mnt/acd-storage.'
rsync -av --exclude 'Downloads' --remove-source-files /mnt/local-storage /mnt/acd-storage
