#!/bin/bash -eu

log "Syncing music archive..."

SRC="/mnt/musicarchive"
DST="/mnt/music"

function connectionmonitor {
  while true
  do
    for i in $(seq 1 10)
    do
      if timeout 3 /root/bin/archive-is-reachable.sh $ARCHIVE_HOST_NAME
      then
        # sleep and then continue outer loop
        sleep 5
        continue 2
      fi
    done
    log "connection dead, killing archive-clips"
    # The archive loop might be stuck on an unresponsive server, so kill it hard.
    # (should be no worse than losing power in the middle of an operation)
    kill -9 $1
    return
  done
}

if ! findmnt --mountpoint $DST
then
  log "$DST not mounted, skipping"
  exit
fi

connectionmonitor $$ &

rsync -avuz --delete $SRC $DST


kill %1

log "sync of music archive finished"

/root/bin/send-push-message "TeslaUSB:" "sync of music archive finished - directories are in sync"
