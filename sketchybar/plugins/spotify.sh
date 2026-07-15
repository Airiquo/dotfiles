#!/bin/bash

RESULT=$(osascript \
  -e 'if application "Spotify" is running then' \
  -e '  tell application "Spotify"' \
  -e '    if player state is playing or player state is paused then' \
  -e '      return (player state as string) & "|||" & (artist of current track) & " — " & (name of current track)' \
  -e '    end if' \
  -e '  end tell' \
  -e 'end if' 2>/dev/null)

if [ -z "$RESULT" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

STATE="${RESULT%%|||*}"
TRACK="${RESULT##*|||}"

if [ ${#TRACK} -gt 45 ]; then
    TRACK="${TRACK:0:45}…"
fi

if [ "$STATE" = "playing" ]; then
    COLOR=0xffffffff
else
    COLOR=0xff888888
fi

sketchybar --set "$NAME" \
    label="󰓇  $TRACK" \
    label.color="$COLOR" \
    drawing=on
