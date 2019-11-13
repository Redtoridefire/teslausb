#!/bin/bash -eu

FILE_PATH="$1"

echo "export user=$RSYNC_USER" > "$FILE_PATH"
echo "export server=$RSYNC_SERVER" >> "$FILE_PATH"
echo "export path=$RSYNC_PATH" >> "$FILE_PATH"
