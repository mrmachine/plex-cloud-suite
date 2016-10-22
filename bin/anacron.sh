#!/usr/bin/env bash

set -e

exec anacron -d -t /opt/etc/anacrontab
