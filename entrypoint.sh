#!/bin/bash
set -u

: "${MODE:?Set MODE}"
: "${SOURCE:?Set SOURCE}"
: "${TARGET:?Set TARGET}"
: "${CRON:=* * * * *}"
OPTIONS="${OPTIONS:-}"

echo "Schedule: $CRON"
echo "Mode: $MODE"
echo "Source: $SOURCE"
echo "Target: $TARGET"
echo "Waiting for scheduled execution..."

LAST_RUN=""

while true; do
    NOW="$(date '+%Y-%m-%d %H:%M')"
    MINUTE="$(date '+%M')"
    HOUR="$(date '+%H')"

    CRON_MINUTE="$(echo "$CRON" | awk '{print $1}')"
    CRON_HOUR="$(echo "$CRON" | awk '{print $2}')"

    if { [ "$CRON_MINUTE" = "*" ] || [ "$CRON_MINUTE" = "$MINUTE" ]; } &&
       { [ "$CRON_HOUR" = "*" ] || [ "$CRON_HOUR" = "$HOUR" ]; } &&
       [ "$LAST_RUN" != "$NOW" ]; then
        LAST_RUN="$NOW"
        echo "========================================"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting rclone"
        echo "========================================"
        set +e
        /usr/bin/rclone "$MODE" "$SOURCE" "$TARGET" $OPTIONS
        STATUS=$?
        set -e
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rclone exited with code $STATUS"
    fi

    sleep 1
done
