#!/bin/bash -eu

log "Moving clips to rclone archive..."

source /root/.teslaCamRcloneConfig

NUM_FILES=0
NUM_FILES_MOVED=0
NUM_FILES_IN_DIR=0

function connectionmonitor {
  while true
  do
    if timeout 5 /root/bin/archive-is-reachable.sh $ARCHIVE_HOST_NAME
    then
      sleep 2
    elif timeout 5 /root/bin/archive-is-reachable.sh $ARCHIVE_HOST_NAME # try one more time
    then
      sleep 2
    else
      log "connection dead, killing archive-clips"
      # The network connection may have been lost, so kill it hard.
      # (should be no worse than losing power in the middle of an operation)
      kill -9 $1
      return
    fi
  done
}

function moveclips() {
  #rclone doesn't remove folders after moving files. This deletes empty directories
  find "$CAM_MOUNT"/TeslaCam/SavedClips/ -type d -empty -delete

  for file_name in "$CAM_MOUNT"/TeslaCam/saved* "$CAM_MOUNT"/TeslaCam/SavedClips/*; do
    [ -e "$file_name" ] || continue
	NUM_FILES_IN_DIR=$(ls "$file_name" | wc -l)
    log "Moving $file_name ..."
    rclone --config /root/.config/rclone/rclone.conf move "$file_name" "$drive:$path" >> "$LOG_FILE" 2>&1 || echo ""
    log "Moved $file_name."
    NUM_FILES_MOVED=$((NUM_FILES_MOVED + NUM_FILES_IN_DIR))
	log "Moved $NUM_FILES_IN_DIR file(s)."
  done
  log "Done moving $NUM_FILES_MOVED file(s)."
}

connectionmonitor $$ &
moveclips

if [ $NUM_FILES_MOVED -gt 0 ]
then
  /root/bin/send-push-message "TeslaUSB:" "Moved $NUM_FILES_MOVED dashcam file(s)."
fi

log "Finished moving clips to rclone archive"
