#!/bin/bash

app_icon() {
  case "$1" in
    Ghostty|Terminal|iTerm2|Alacritty|kitty|WezTerm)  echo "" ;;
    Emacs)                                            echo "" ;;
    "Visual Studio Code"|VSCodium|Cursor)             echo "󰨞" ;;
    "Google Chrome")                                  echo "" ;;
    Safari|Arc)                                       echo "󰖟" ;;
    Slack)                                            echo "󰒱" ;;
    Spotify)                                          echo "󰓇" ;;
    Discord)                                          echo "󰙯" ;;
    Finder)                                           echo "󰉋" ;;
    Mail)                                             echo "󰇮" ;;
    Calendar)                                         echo "󰃭" ;;
    Zoom)                                             echo "󰊾" ;;
    *)                                                echo "󰘔" ;;
  esac
}

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  bg_state="on"
else
  bg_state="off"
fi

# Update underline immediately before the slower aerospace query
sketchybar --set "$NAME" background.drawing="$bg_state"

# Unique app names in this workspace
apps=$(aerospace list-windows --workspace "$1" 2>/dev/null \
  | awk -F'|' 'NF>=2 {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}' \
  | sort -u)

icons=""
count=0
while IFS= read -r app; do
  [[ -z "$app" ]] && continue
  [ "$count" -ge 5 ] && break
  icons="${icons}$(app_icon "$app") "
  count=$((count + 1))
done <<< "$apps"
icons="${icons% }"

[ -n "$icons" ] && label=" $icons" || label=""
padding_right=$((4 + count * 4))

sketchybar --set "$NAME" \
  background.drawing="$bg_state" \
  padding_right="$padding_right" \
  label="$label"
