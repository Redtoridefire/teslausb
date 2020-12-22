#!/bin/bash -eu

FILE_PATH="$1"

(
  echo "username=$SHARE_USER"
  echo "password=$SHARE_PASSWORD"
  echo "domain=$SHARE_DOMAIN"
) > "$FILE_PATH"
