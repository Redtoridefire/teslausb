#!/bin/bash -eu

FILE_PATH="$1"

echo "export drive=$RCLONE_DRIVE" > "$FILE_PATH"
echo "export path=$RCLONE_PATH" >> "$FILE_PATH"
