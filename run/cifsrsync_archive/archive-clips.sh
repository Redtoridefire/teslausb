#!/bin/bash -eu

log "syncing clips to archive..."

success=0
fails=0
total=0


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

function syncclips(){
   log "function syncclips $1 ---> $(find $ROOT -mindepth 1  -type d ! -name \".\")"
   ROOT="$1"
   DIR=$(basename $ROOT)
   mkdir -p $ARCHIVE_MOUNT/$DIR

   for i in $(find $ROOT -mindepth 1 -type d ! -name "."); do
       log "Syncing $i to $ARCHIVE_MOUNT/$DIR"
       rsync -au $i $ARCHIVE_MOUNT/$DIR > /mutuable/rsync.log 2>&1
	if [ $? -eq 0 ]; then
		rm -rf $i
       		log "synced dir $i"
       		let success=success+1
	else
		let fails=fails+1
		log "rsync failed"
                log $(cat /mutuable/rsync.log")
	fi
	let totals=totals+1
	rm -f /mutuable/rsync.log
   done
}

connectionmonitor $$ &

# new file name pattern, firmware 2019.*
log "syncing saved clips"
syncclips "$CAM_MOUNT/TeslaCam/SavedClips" 
log "now syncing sentry files"
# v10 firmware adds a SentryClips folder
syncclips "$CAM_MOUNT/TeslaCam/SentryClips" 

kill %1

log "successfully synced $success and removed dirs, failed on $fails, in total $total"

if [ $success -gt 0 ]
then
  /root/bin/send-push-message "TeslaUSB:" "successfully synced $success and removed dirs, failed on $fails, in total $total"
fi

log "Finished rsync over CIFS"
