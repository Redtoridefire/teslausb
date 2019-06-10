#!/bin/bash -eu

# Call wake_up_vehicle Tesla API every 120 seconds
# as long as rsync is running. This has to be run
# in the background.  
function keepVehicleAwake() {
  if [ -f /root/bin/tesla_api.py ]
    then
    while :
    do
      sleep 120
      PROC_COUNT=$(pgrep -c rsync)
      if [ "$PROC_COUNT" == "0" ]
      then
        log "Rsync done. Exiting wake_up_vehicle loop."
        break
      else
        /root/bin/tesla_api.py wake_up_vehicle >> "$LOG_FILE"
      fi
    done
  fi
}
keepVehicleAwake&

log "Archiving through rsync..."

source /root/.teslaCamRsyncConfig

num_files_moved=$(rsync -auvh --remove-source-files --no-perms --stats --log-file=/tmp/archive-rsync-cmd.log /mnt/cam/TeslaCam/saved* /mnt/cam/TeslaCam/SavedClips/* $user@$server:$path | awk '/files transferred/{print $NF}')

/root/bin/send-push-message "$num_files_moved"

if (( $num_files_moved > 0 ))
then
  find /mnt/cam/Teslacam/SavedClips/ -depth -type d -empty -exec rmdir "{}" \;
  log "Successfully synced files through rsync."
else
  log "No files to archive through rsync."
fi
