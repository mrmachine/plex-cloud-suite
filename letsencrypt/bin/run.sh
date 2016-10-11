#!/bin/bash

set -e

nginx.sh
update-certs.sh
crond -f
