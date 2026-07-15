local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250

local wifi = Sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  label = { drawing = false },
})

local wifi_bracket = Sbar.add("bracket", "widgets.wifi.bracket", {
  wifi.name,
}, {
    background = { color = colors.bg05, border_color = colors.bg1, border_width = 1 },
    padding_right=1,
  popup = { align = "center", height = 30, blur_radius = 16, background = { border_width = 1, border_color = colors.bg2, color = colors.bg1 } }
})

local ssid = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    font = { style = settings.font.style_map["Bold"] },
    string = icons.wifi.router,
  },
  width = popup_width,
  align = "center",
  label = {
    font = { size = 15, style = settings.font.style_map["Bold"] },
    max_chars = 18,
    string = "????????????",
  },
  background = { height = 2, color = colors.grey, y_offset = -15 }
})

local hostname = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = { align = "left", string = "hostname ~>", width = popup_width / 2 },
  label = { max_chars = 20, string = "????????????", width = popup_width / 2, align = "right" }
})

local ip = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = { align = "left", string = "IP:", width = popup_width / 2 },
  label = { string = "???.???.???.???", width = popup_width / 2, align = "right" }
})

local mask = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = { align = "left", string = "Subnet mask:", width = popup_width / 2 },
  label = { string = "???.???.???.???", width = popup_width / 2, align = "right" }
})

local router = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = { align = "left", string = "Router:", width = popup_width / 2 },
  label = { string = "???.???.???.???", width = popup_width / 2, align = "right" },
})

Sbar.add("item", { position = "right", width = settings.group_paddings })

local function paint_status()
  Sbar.exec("ipconfig getifaddr en0", function(ip_addr)
    local connected = not (ip_addr == "")
    wifi:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.red,
      },
    })
  end)
end

wifi:subscribe({"wifi_change", "system_woke"}, paint_status)

local function hide_details()
  wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    wifi_bracket:set({ popup = { drawing = true }})
    Sbar.exec("networksetup -getcomputername", function(result)
      hostname:set({ label = result })
    end)
    Sbar.exec("ipconfig getifaddr en0", function(result)
      ip:set({ label = result })
    end)
    Sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      ssid:set({ label = result })
    end)
    Sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
      mask:set({ label = result })
    end)
    Sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
      router:set({ label = result })
    end)
  else
    hide_details()
  end
end

wifi:subscribe("mouse.clicked", toggle_details)
wifi_bracket:subscribe("mouse.exited", hide_details)

local function copy_label_to_clipboard(env)
  local label = Sbar.query(env.NAME).label.value
  Sbar.exec("echo \"" .. label .. "\" | pbcopy")
  Sbar.set(env.NAME, { label = { string = icons.clipboard, align="center" } })
  Sbar.delay(1, function()
    Sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)

Sbar.delay(0.5, paint_status)
