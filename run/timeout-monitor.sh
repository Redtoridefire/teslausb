#!/bin/bash

PARENT_ID=$1
LAST_MODIFIED_SECONDS=0
TIMEOUT=300
FILE_NAME=$2

echo "Started Monitoring process $PARENT_ID and file $FILE_NAME" >> /mutable/timeout.log

while ((LAST_MODIFIED_TIME < TIMEOUT))
do
  FILE_LAST_MODIFIED=$(date +%s -r $FILE_NAME)
  CURRENT_SECONDS=$(date +%s)
  LAST_MODIFIED_TIME=$((CURRENT_SECONDS - FILE_LAST_MODIFIED))
  sleep 30
done

kill -9 $PARENT_ID
