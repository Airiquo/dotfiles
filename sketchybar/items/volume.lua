local colors = require("colors")
local icons = require("icons")

local volume_slider = Sbar.add("slider", 100, {
  position = "right",
  updates = true,
  label = { drawing = false },
    icon = { drawing = false },
    padding_left = 2,
    padding_right = 0,
  slider = {
    highlight_color = colors.blue,
    width = 0,
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.with_alpha(colors.white, 0.3),
    },
    knob = {
      string = "􀀁",
      drawing = true,
    },
  },
})

local volume_icon = Sbar.add("item", {
  position = "right",
  icon = {
        string = icons.volume._100,
        highlight = true,
        -- highlight_color = colors.blue,
    width = 0,
    align = "left",
    color = colors.grey,
    font = {
      style = "Bold",
      size = 14.0,
    },
  },
  label = {
        width = 28,
    -- highlight = true,
    -- highlight_color = colors.blue,
    align = "left",
    font = {
      style = "Bold",
      size = 14.0,
    },
  },
})

local function icon_for(volume)
  if volume > 60 then return icons.volume._100
  elseif volume > 30 then return icons.volume._66
  elseif volume > 10 then return icons.volume._33
  elseif volume > 0 then return icons.volume._10
  else return icons.volume._0 end
end

volume_slider:subscribe("mouse.clicked", function(env)
  local pct = tonumber(env["PERCENTAGE"])
  Sbar.exec("osascript -e 'set volume output volume " .. env["PERCENTAGE"] .. "'")
  if pct then
    volume_icon:set({ label = icon_for(pct) })
    volume_slider:set({ slider = { percentage = pct } })
  end
end)

volume_slider:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  if not volume or volume <= 0 then return end
  volume_icon:set({ label = icon_for(volume) })
  volume_slider:set({ slider = { percentage = volume } })
end)

local function animate_slider_width(width)
  Sbar.animate("tanh", 30.0, function()
    volume_slider:set({ slider = { width = width }})
  end)
end

volume_icon:subscribe("mouse.clicked", function()
  if tonumber(volume_slider:query().slider.width) > 0 then
    animate_slider_width(0)
  else
    animate_slider_width(100)
  end
end)

-- Paint the current system volume on load so the slider/icon aren't
-- blank until the next volume change.
Sbar.exec("osascript -e 'output volume of (get volume settings)'", function(vol)
  local volume = tonumber(vol)
  if not volume or volume <= 0 then return end
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end
  volume_icon:set({ label = icon })
  volume_slider:set({ slider = { percentage = volume } })
end)
