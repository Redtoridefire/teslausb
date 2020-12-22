#!/bin/bash -eu

FILE_PATH="$1"

if [[ "$DOMAIN_ENABLE" = false ]]; then
  (
    echo "username=$SHARE_USER"
    echo "password=$SHARE_PASSWORD"
  ) > "$FILE_PATH"
else
  (
    echo "username=$SHARE_USER"
    echo "password=$SHARE_PASSWORD"
    echo "domain=$SHARE_DOMAIN"
  ) > "$FILE_PATH"
fi