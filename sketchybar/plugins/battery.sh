#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep -c "AC Power")

if [ "$CHARGING" -gt 0 ]; then
  sketchybar --set "$NAME" label="+[$PERCENTAGE%]"
else
  sketchybar --set "$NAME" label="[$PERCENTAGE%]"
fi
