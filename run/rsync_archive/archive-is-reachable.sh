#!/bin/bash -eu

ARCHIVE_HOST_NAME="$1"

ssh -q "$RSYNC_USER"@"$ARCHIVE_HOST_NAME" exit
