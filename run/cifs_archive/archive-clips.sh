#!/bin/bash -eu

log "syncing clips to archive..."

success=0
fails=0
total=0
totalFiles=0


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
   ROOT="$1"
   #log "function syncclips $1 ---> $(find $ROOT -mindepth 1  -type d)"
   DIR=$(basename $ROOT)
   mkdir -p $ARCHIVE_MOUNT/$DIR

   for i in $(find $ROOT -mindepth 1 -type d ); do
       #log "Syncing $i to $ARCHIVE_MOUNT/$DIR"
       num_files_moved=$(rsync -avuh --timeout=60 --remove-source-files --no-perms --stats --log-file=/mutable/rsync.log $i $ARCHIVE_MOUNT/$DIR | awk '/files transferred/{print $NF}')
	if [ $? -eq 0 ]; then
		rm -rf $i
       		#log "synced dir $i"
       		let success=success+1
		let totalFiles=totalFiles+num_files_moved
	else
		let fails=fails+1
		log "rsync failed"
                log $(cat /mutable/rsync.log)
	fi
	let totals=totals+1
	rm -f /mutable/rsync.log
   done
}

connectionmonitor $$ &

# new file name pattern, firmware 2019.*
#log "syncing saved clips"
syncclips "$CAM_MOUNT/TeslaCam/SavedClips" 
#log "now syncing sentry files"
# v10 firmware adds a SentryClips folder
syncclips "$CAM_MOUNT/TeslaCam/SentryClips" 

kill %1

log "successfully synced $success and removed dirs, failed on $fails, in total $total, files $totalFiles"

if [ $success -gt 0 ]
then
  /root/bin/send-push-message "TeslaUSB:" "successfully synced and removed $success dirs, failed on $fails, in total $total dirs and $totalFiles files were transfered"
fi

log "Finished rsync over CIFS"
