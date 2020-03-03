#!/bin/bash -eu

source /root/.teslaCamRcloneConfig

function send_completed_sns () {
  log "Sending SNS message $1 for completed upload."

  source /root/.teslaCamSNSTopicARN

  # shellcheck disable=SC2154
  python3 /root/bin/send_sns.py -t "$sns_topic_arn" -s "TeslaCam Upload" -m "$1"
}

log "Moving clips to rclone archive..."

FILE_COUNT=$(cd "$CAM_MOUNT"/TeslaCam && find . -maxdepth 3 -path './SavedClips/*' -type f -o -path './SentryClips/*' -type f | wc -l)

for clipfolder in "$CAM_MOUNT"/TeslaCam/SavedClips "$CAM_MOUNT"/TeslaCam/SentryClips
do
  if [ -d "$clipfolder" ]; then
    clipfolderbase="${clipfolder##*/}"
    for folder in "$clipfolder"/*; do
      if [ -d "${folder}" ]; then
        folderbase="${folder##*/}"
        log "rclone uploading $clipfolderbase/$folderbase"
        # shellcheck disable=SC2154
        rclone --config /root/.config/rclone/rclone.conf move "$clipfolder/$folderbase" "$drive:$path/$clipfolderbase/$folderbase" --create-empty-src-dirs --delete-empty-src-dirs >> "$LOG_FILE" 2>&1 || true
        rmdir "$folder"
        /root/bin/send-push-message "TeslaUSB:" "Uploaded $clipfolderbase/$folderbase" || true
        [ -r "/root/.teslaCamSNSTopicARN" ] && send_completed_sns "$clipfolderbase/$folderbase"
      fi
    done
  fi
done


FILES_REMAINING=$(cd "$CAM_MOUNT"/TeslaCam && find . -maxdepth 3 -path './SavedClips/*' -type f -o -path './SentryClips/*' -type f | wc -l)
NUM_FILES_MOVED=$((FILE_COUNT-FILES_REMAINING))

log "Moved $NUM_FILES_MOVED file(s)."
/root/bin/send-push-message "TeslaUSB:" "Moved $NUM_FILES_MOVED dashcam file(s)."

log "Finished moving clips to rclone archive"
