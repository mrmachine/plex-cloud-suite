#!/bin/sh

set -e

exec transmission-daemon --config-dir /mnt/storage/Docker/transmission --foreground
