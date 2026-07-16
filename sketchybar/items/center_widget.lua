local colors   = require("colors")
local settings = require("settings")

local FOCUS_QUERY = "aerospace list-windows --focused --format '%{app-name}|%{window-title}' 2>/dev/null"

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

local function render_focused(app, title)
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

local function refresh_focused()
  Sbar.exec(FOCUS_QUERY, function(out)
    if not out then render_focused(nil, nil); return end
    local line = out:gsub("%s*$", "")
    if line == "" then render_focused(nil, nil); return end
    local app, title = line:match("^([^|]*)|(.*)$")
    render_focused(app, title)
  end)
end

Sbar.add("item", "widgets.center.watcher", {
  drawing = false,
  updates = true,
}):subscribe(
  { "aerospace_focus_change", "aerospace_workspace_change", "system_woke", "forced" },
  refresh_focused
)

Sbar.delay(0.5, refresh_focused)
