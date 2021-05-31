#!/bin/bash -eu

log "Starting - music_rsync"

DST="/mnt/music"
LOG="/tmp/rsyncmusicresults.txt"

rsync -rum --no-human-readable --timeout=60 --no-perms --omit-dir-times --info=stats2 \
      --log-file=/tmp/rsyncmusic.log --ignore-missing-args \
      --exclude=.metadata_never_index \
      "$RSYNC_USER@$RSYNC_SERVER:$RSYNC_MUSIC" $DST  &> $LOG 

  # remove empty directories
  find $DST -depth -type d -empty -delete || true

  # parse log for relevant info
  declare -i NUM_FILES_COPIED
  NUM_FILES_COPIED=$(($(sed -n -e 's/\(^Number of regular files transferred: \)\([[:digit:]]\+\).*/\2/p' "$LOG")))
  declare -i NUM_FILES_DELETED
  NUM_FILES_DELETED=$(($(sed -n -e 's/\(^Number of deleted files: [[:digit:]]\+ (reg: \)\([[:digit:]]\+\)*.*/\2/p' "$LOG")))
  declare -i TOTAL_FILES
  TOTAL_FILES=$(sed -n -e 's/\(^Number of files: [[:digit:]]\+ (reg: \)\([[:digit:]]\+\)*.*/\2/p' "$LOG")
  declare -i NUM_FILES_ERROR
  NUM_FILES_ERROR=$(($(grep -c "failed to open" $LOG || true)))

  declare -i NUM_FILES_SKIPPED=$((TOTAL_FILES-NUM_FILES_COPIED))
  NUM_FILES_COPIED=$((NUM_FILES_COPIED-NUM_FILES_ERROR))

  log "Copied $NUM_FILES_COPIED music file(s), deleted $NUM_FILES_DELETED, skipped $NUM_FILES_SKIPPED previously-copied files, and encountered $NUM_FILES_ERROR errors."

  if [ $NUM_FILES_COPIED -ne 0 ] || [ $NUM_FILES_DELETED -ne 0 ] || [ $NUM_FILES_ERROR -ne 0 ]
  then
    /root/bin/send-push-message "$TESLAUSB_HOSTNAME:" "Copied $NUM_FILES_COPIED music file(s), deleted $NUM_FILES_DELETED, skipped $NUM_FILES_SKIPPED previously-copied files, and encountered $NUM_FILES_ERROR errors."
  fi

log "Done - music_rsync"
