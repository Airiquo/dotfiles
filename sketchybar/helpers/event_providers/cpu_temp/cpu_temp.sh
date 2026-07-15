#!/bin/bash
sketchybar --add event cpu_temp_update

WINDOW_SIZE=4
declare -a TEMPS=()

macmon pipe -i 1000 | jq --unbuffered -r '.temp.cpu_temp_avg' | while IFS= read -r TEMP; do
  if [ -n "$TEMP" ] && [ "$TEMP" != "null" ]; then
    TEMPS+=("$TEMP")
    if [ "${#TEMPS[@]}" -gt "$WINDOW_SIZE" ]; then
      TEMPS=("${TEMPS[@]:1}")
    fi

    SUM=0
    for T in "${TEMPS[@]}"; do
      SUM=$(echo "$SUM + $T" | bc)
    done
    OFFSET=6
    AVG=$(echo "scale=1; ($SUM / ${#TEMPS[@]}) - $OFFSET" | bc)

    sketchybar --trigger cpu_temp_update temp="${AVG%.*}"
  fi
done