local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

Sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")
Sbar.exec("killall cpu_temp.sh >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_temp/cpu_temp.sh &")

local last_temp = "--"
local last_load = 0

local cpu = Sbar.add("graph", "widgets.cpu", 50, {
  position = "right",
  graph = { color = colors.blue },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.cpu },
label = {
  string = "CPU ??%",
  font = {
    family = settings.font.numbers,
    style = settings.font.style_map["Medium"],
    size = 10.0,
  },
  align = "right",
  padding_right = 0,
  width = 25,
  y_offset = 4
},
  padding_right = settings.paddings + 6
})

local function render(load)
  local color = colors.blue
  if load > 30 then
    if load < 60 then color = colors.yellow
    elseif load < 80 then color = colors.orange
    else color = colors.red end
  end
  cpu:set({
    graph = { color = color },
    label = { string = load .. "% \195\183 " .. last_temp .. "\194\176C", align = "right" },
  })
end

cpu:subscribe("cpu_update", function(env)
  local load = tonumber(env.total_load)
  cpu:push({ load / 100. })
  last_load = load
  render(load)
end)

cpu:subscribe("cpu_temp_update", function(env)
  last_temp = env.temp
  render(last_load)
end)

Sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
  background = { color = colors.bg05, border_color = colors.bg1, border_width = 1 }
})

Sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})
