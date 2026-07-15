#!/bin/bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "$DIR/sketchybar" ~/.config/sketchybar
ln -sf "$DIR/cava" ~/.config/cava
ln -sf "$DIR/aerospace.toml" ~/.aerospace.toml
echo "Symlinks created. Run: sketchybar --reload && aerospace reload-config"
