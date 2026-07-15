#!/bin/bash
FIFO=/tmp/cava_sketchybar.fifo
[ -p "$FIFO" ] || mkfifo "$FIFO"

sketchybar --add event cava_update

BLOCKS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

cava -p "$HOME/.config/cava/sketchybar_config" &
CAVA_PID=$!
trap "kill $CAVA_PID 2>/dev/null" EXIT

while IFS=';' read -ra VALUES; do
  BARS=""
  ACTIVE=0
  for v in "${VALUES[@]}"; do
    [ -z "$v" ] && continue
    idx=$v
    if [ "$idx" -gt 7 ]; then idx=7; fi
    if [ "$idx" -gt 0 ]; then ACTIVE=1; fi
    BARS+="${BLOCKS[$idx]}"
  done
  sketchybar --trigger cava_update bars="$BARS" playing="$ACTIVE"
done < "$FIFO"
