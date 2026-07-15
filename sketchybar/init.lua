os.execute("[ ! -d $HOME/.local/share/sketchybar_lua/ ] && (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)")

local HOME = os.getenv("HOME")
package.cpath = package.cpath .. ";" .. HOME .. "/.local/share/sketchybar_lua/?.so"

---@type SbarModule
Sbar = require("sketchybar")

Sbar.begin_config()
Sbar.hotload(true)
require("helpers.utils")
require("bar")
require("default")
require("items")
Sbar.end_config()
Sbar.event_loop()
