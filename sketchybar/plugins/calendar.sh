#!/bin/bash

BINARY="$HOME/.cache/sketchybar/calendar-events"

RESULT=$("$BINARY" 2>/dev/null)

[ -z "$RESULT" ] && sketchybar --set "$NAME" drawing=off && exit 0

NOW=$(date +%s)

# Collect events: starting within 15 mins, or started up to 5 mins ago
EVENTS=()
while IFS= read -r EVENT; do
    TS="${EVENT%%|||*}"
    TITLE="${EVENT##*|||}"
    [ -z "$TS" ] && continue
    DELTA=$((TS - NOW))
    [ "$DELTA" -lt -300 ] || [ "$DELTA" -gt 900 ] && continue
    EVENTS+=("$TS|||$TITLE")
done <<< "$RESULT"

if [ "${#EVENTS[@]}" -eq 0 ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

# Sort descending by timestamp so most imminent ends up rightmost in the label
IFS=$'\n' SORTED=($(printf '%s\n' "${EVENTS[@]}" | sort -t'|' -k1 -rn))
unset IFS

LABEL=""
HAS_RED=false

for EVENT in "${SORTED[@]}"; do
    TS="${EVENT%%|||*}"
    TITLE="${EVENT##*|||}"
    DELTA=$((TS - NOW))
    TIME=$(date -r "$TS" +"%H:%M")

    if [ -n "$LABEL" ]; then
        LABEL="$LABEL  $TIME $TITLE"
    else
        LABEL="$TIME $TITLE"
    fi

    [ "$DELTA" -gt 0 ] && [ "$DELTA" -le 120 ] && HAS_RED=true
done

if [ "$HAS_RED" = true ]; then
    COLOR=0xFFFF3B30
else
    COLOR=0xFFFFFFFF
fi

sketchybar --set "$NAME" label="$LABEL" label.color="$COLOR" drawing=on
