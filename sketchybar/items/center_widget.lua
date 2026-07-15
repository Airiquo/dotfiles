local colors   = require("colors")
local settings = require("settings")

local IDLE_SECONDS      = 3
local FRESHNESS_SECONDS = 5

local FOCUS_QUERY = "aerospace list-windows --focused --format '%{app-name}|%{window-title}' 2>/dev/null"

Sbar.exec("killall cava_bar.sh >/dev/null; $CONFIG_DIR/helpers/event_providers/cava_bar/cava_bar.sh &")
Sbar.exec("sketchybar --add event aerospace_focus_change")

local widget = Sbar.add("item", "widgets.center", {
  position = "center",
  updates  = true,
  icon = {
    drawing       = true,
    background    = { drawing = true, image = { scale = 0.9, clip = 0.8 } },
    padding_right = 6,
  },
  label = {
    font      = { family = settings.font.text, style = "Semibold", size = 12.0 },
    color     = colors.white,
    max_chars = 60,
  },
  padding_left  = settings.paddings,
  padding_right = settings.paddings,
})

local generation      = 0
local is_playing      = false
local last_playing_ts = 0
local cava_bars       = ""
local showing_cava    = false

local function currently_playing()
  return is_playing and (os.time() - last_playing_ts) < FRESHNESS_SECONDS
end

local function render_focused(app, title)
  showing_cava = false
  if not app or app == "" then
    widget:set({
      icon  = { background = { drawing = false } },
      label = {
        string = "Desktop",
        color  = colors.grey,
        font   = { family = settings.font.text, style = "Semibold", size = 12.0 },
      },
    })
    return
  end
  local text = app
  if title and title ~= "" then
    text = app .. "  —  " .. title
  end
  widget:set({
    icon = {
      background = {
        drawing = true,
        image   = { string = "app." .. app, scale = 0.9, clip = 0.8 },
      },
    },
    label = {
      string = text,
      color  = colors.white,
      font   = { family = settings.font.text, style = "Semibold", size = 12.0 },
    },
  })
end

local function render_cava()
  showing_cava = true
  widget:set({
    icon  = { background = { drawing = false } },
    label = {
      string = cava_bars,
      color  = colors.puce,
      font   = { family = "SF Mono", style = "Bold", size = 13.0 },
    },
  })
end

local function refresh_focused()
  Sbar.exec(FOCUS_QUERY, function(out)
    if not out then render_focused(nil, nil); return end
    local line = out:gsub("%s*$", "")
    if line == "" then render_focused(nil, nil); return end
    local app, title = line:match("^([^|]*)|(.*)$")
    render_focused(app, title)
  end)
end

local function on_focus_activity()
  generation = generation + 1
  local my_generation = generation
  refresh_focused()
  Sbar.delay(IDLE_SECONDS, function()
    if generation ~= my_generation then return end
    if currently_playing() then render_cava() end
  end)
end

widget:subscribe(
  { "aerospace_focus_change", "aerospace_workspace_change", "system_woke", "forced" },
  on_focus_activity
)

widget:subscribe("cava_update", function(env)
  cava_bars  = env.bars or ""
  is_playing = (env.playing == "1")
  if is_playing then last_playing_ts = os.time() end
  -- Live-update every incoming frame, but only while cava is actually
  -- the visible mode — avoids pointless :set() calls while the widget
  -- is showing the focused window instead.
  if showing_cava then
    widget:set({ label = { string = cava_bars } })
  end
end)

Sbar.delay(0.5, on_focus_activity)
