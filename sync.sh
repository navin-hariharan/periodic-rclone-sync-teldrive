#!/bin/sh

if [ "$(($(date +%s) / 60 % ${INTERVAL}))" -eq "0" ]; then
  echo "==== $(date) Starting rclone sync ===="
  rclone sync "${SOURCE}" "${TARGET}" ${OPTIONS}
  echo "periodic-rclone-sync complete: ${SOURCE} → ${TARGET}"
  echo "==== $(date) Sync finished ===="
fi
