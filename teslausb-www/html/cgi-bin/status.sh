#!/bin/bash

cat << EOF
HTTP/1.0 200 OK
Content-type: text/plain

EOF

uptime
vcgencmd measure_volts core
vcgencmd measure_temp
eval "$(stat --file-system --format="echo \$((%b*%S))" /backingfiles/cam_disk.bin)"
eval "$(stat --file-system --format="echo \$((%f*%S))" /backingfiles/cam_disk.bin)"
find /backingfiles/snapshots/ -name snap.bin 2> /dev/null | wc -l
