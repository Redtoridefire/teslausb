#!/bin/bash -eu
if [ -e /tmp/not_reachable ]; then
   log "overriding - archive not reachable"
   exit 1
fi
if [ -e /tmp/reachable ]; then
   log "overriding - archive reachable"
   exit 0
fi

ARCHIVE_HOST_NAME="$1"

hping3 -c 1 -S -p 445 "$ARCHIVE_HOST_NAME" > /dev/null 2>&1
