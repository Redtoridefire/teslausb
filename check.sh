#! /bin/bash

# SC1091 - Don't complain about not being able to find files that don't exist.

EXCLUSIONS=SC1091

# print shellcheck version so we know what Github uses
shellcheck -V

shellcheck --exclude=$EXCLUSIONS \
           ./setup/pi/setup-teslausb \
           ./pi-gen-sources/00-teslausb-tweaks/files/rc.local \
           ./run/archiveloop \
           ./run/auto.teslausb \
           ./run/remountfs_rw \
           ./run/send-push-message \
           ./run/waitforidle

find . -type f -name '*.sh' -print0 | xargs -0 shellcheck --exclude=$EXCLUSIONS --external-sources "$@" || true
