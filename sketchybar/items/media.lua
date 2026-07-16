local settings     = require "settings"
local colors       = require("colors")
local icons        = require("icons")

local ARTWORK_PATH = "/tmp/sketchybar_spotify_artwork.jpg"

local SCRIPT       = [[
osascript -e '
tell application "System Events"
  set spotifyRunning to (name of processes) contains "Spotify"
end tell
if spotifyRunning then
  tell application "Spotify"
    try
      set s to player state as string
      set a to artist of current track
      set t to name of current track
      set u to artwork url of current track
      return s & "|" & a & "|" & t & "|" & u
    on error
      return "paused|||"
    end try
  end tell
else
  return "stopped|||"
end if
' 2>/dev/null || echo 'stopped|||'
]]

local media_cover  = Sbar.add("item", "media.cover", {
    position   = "right",
    drawing    = false,
    icon       = { drawing = false },
    label      = { drawing = false },
    padding_right = 8,
    background = {
        image = {
            string = ARTWORK_PATH,
            border_color = colors.bg0,
            border_width = 1,
            corner_radius = 4,
            scale = 0.0375
        },
        x_offset = 1,
        color = colors.transparent,
    },
})

local media_artist = Sbar.add("item", "media.artist", {
    position = "right",
    drawing  = false,
    padding_left  = 0,
    padding_right = 0,
    width    = 0,
    icon     = { drawing = false },
    label    = {
        width     = "dynamic",
        font      = { family = settings.font.text_round, size = 10, style = "Regular" },
        color     = colors.with_alpha(colors.white, 0.88),
        max_chars = 18,
        y_offset  = 6,
    },
})

local media_title  = Sbar.add("item", "media.title", {
    position = "right",
    drawing  = false,
    padding_left  = 8,
    padding_right = 0,
    icon     = { drawing = false },
    label    = {
        font      = { family = settings.font.text_round, style = "Medium", size = 11 },
        width     = "dynamic",
        max_chars = 24,
        y_offset  = -5,
    },
})

local media_cava = Sbar.add("item", "media.cava", {
    position      = "right",
    drawing       = false,
    padding_left  = 0,
    padding_right = 4,
    icon          = { drawing = false },
    label         = {
        string   = "",
        font     = { family = "SF Mono", style = "Bold", size = 11 },
        color    = colors.puce,
        y_offset = 0,
        width    = 110,
        align    = "left",
    },
    popup = {
        align  = "center",
        height = 30,
        background = {
            border_width = 1,
            border_color = colors.bg2,
            color        = colors.bg1,
        },
    },
})

local mbracket     = Sbar.add("bracket", "media.bracket", {
    media_artist.name,
    media_title.name,
    media_cava.name,
    media_cover.name,
}, {
    background = {
        color         = colors.bg05,
        border_color  = colors.bg1,
        border_width = 1
    },
    popup = {
        align      = "center",
        horizontal = true,
    }
})


local popup_cover = Sbar.add("item", {
    position   = "popup." .. mbracket.name,
    background = {
        image = {
            string        = ARTWORK_PATH,
            scale         = 0.25,
            corner_radius = 12,
        },
        color = colors.transparent,
    },
    label      = { drawing = false },

})

local bwd = Sbar.add("item", {
    position     = "popup." .. mbracket.name,
    icon         = { string = icons.media.back },
    label        = { drawing = false },
    click_script = "osascript -e 'tell application \"Spotify\" to previous track'",
})
local pp = Sbar.add("item", {
    position     = "popup." .. mbracket.name,
    icon         = { string = icons.media.play_pause },
    label        = { drawing = false },
    click_script = "osascript -e 'tell application \"Spotify\" to playpause'",
})
local fwd = Sbar.add("item", {
    position     = "popup." .. mbracket.name,
    icon         = { string = icons.media.forward },
    label        = { drawing = false },
    click_script = "osascript -e 'tell application \"Spotify\" to next track'",
})

-- ============================================================
-- Volume popup, attached to the cava item specifically
-- ============================================================
local popup_vol_slider = Sbar.add("slider", 120, {
    position = "popup." .. media_cava.name,
    updates  = true,
    label    = { drawing = false },
    icon     = { drawing = false },
    padding_left  = 4,
    padding_right = 0,
    slider = {
        highlight_color = colors.blue,
        width = 120,
        background = {
            height = 6,
            corner_radius = 3,
            color = colors.with_alpha(colors.white, 0.3),
        },
        knob = {
            string = "●",
            drawing = true,
        },
    },
})

local function vol_icon_for(volume)
    if volume > 60 then return icons.volume._100
    elseif volume > 30 then return icons.volume._66
    elseif volume > 10 then return icons.volume._33
    elseif volume > 0 then return icons.volume._10
    else return icons.volume._0 end
end

local function hide_cava_popup()
    media_cava:set({ popup = { drawing = false } })
end

local function toggle_cava_popup()
    local should_draw = media_cava:query().popup.drawing == "off"
    media_cava:set({ popup = { drawing = should_draw } })
end

media_cava:subscribe("mouse.clicked", toggle_cava_popup)
media_cava:subscribe("mouse.exited.global", hide_cava_popup)

popup_vol_slider:subscribe("mouse.clicked", function(env)
    local pct = tonumber(env["PERCENTAGE"])
    Sbar.exec("osascript -e 'set volume output volume " .. env["PERCENTAGE"] .. "'")
    if pct then
        popup_vol_slider:set({ slider = { percentage = pct } })
    end
end)

popup_vol_slider:subscribe("volume_change", function(env)
    local volume = tonumber(env.INFO)
    if not volume or volume <= 0 then return end
    popup_vol_slider:set({ slider = { percentage = volume } })
end)

Sbar.exec("osascript -e 'output volume of (get volume settings)'", function(vol)
    local volume = tonumber(vol)
    if not volume or volume <= 0 then return end
    popup_vol_slider:set({ slider = { percentage = volume } })
end)

local interrupt = 0

-- ============================================================
-- Mouse events (media bracket popup)
-- ============================================================
local function hide_popup()
    mbracket:set({ popup = { drawing = false } })
end

local function toggle_popup()
    local should_draw = mbracket:query().popup.drawing == "off"
    mbracket:set({ popup = { drawing = should_draw } })
end

media_cover:subscribe("mouse.clicked", toggle_popup)
media_artist:subscribe("mouse.clicked", toggle_popup)
media_title:subscribe("mouse.clicked", toggle_popup)

media_cover:subscribe("mouse.exited.global", hide_popup)

-- ============================================================
-- Cava (only runs while Spotify is actually playing)
-- ============================================================
Sbar.exec("sketchybar --add event cava_update")

local cava_running = false

local function stop_cava()
    if cava_running then
        Sbar.exec("killall cava_bar.sh cava >/dev/null 2>&1")
        cava_running = false
    end
end

local function start_cava()
    if not cava_running then
        Sbar.exec("$CONFIG_DIR/helpers/event_providers/cava_bar/cava_bar.sh &")
        cava_running = true
    end
end

media_cava:subscribe("cava_update", function(env)
    media_cava:set({ label = { string = env.bars or "" } })
end)

-- ============================================================
-- Refresh
-- ============================================================
local last_url = nil

local function set_artwork(url)
    if url == nil or url == "" then return end
    if url == last_url then return end
    last_url = url
    local cmd = string.format(
        "curl -sL %q -o %q && echo ok",
        url, ARTWORK_PATH
    )
    Sbar.exec(cmd, function(out)
        if out and out:match("ok") then
            media_cover:set({
                background = {
                    image = {
                        string = ARTWORK_PATH,
                        border_color = colors.bg0,
                        border_width = 1,
                        corner_radius = 4,
                        scale = 0.0375
                    },
                    x_offset = 1,
                    color = colors.transparent,
                },
            })
            popup_cover:set({ background = { image = { string = ARTWORK_PATH } } })
        end
    end)
end

local function refresh()
    Sbar.exec(SCRIPT, function(raw)
        if not raw then return end
        raw = raw:gsub("%s+$", "")

        local state, artist, title, url = raw:match("^(%S+)%|(.-)%|(.-)%|(.*)$")
        if not state then return end

        local playing = state == "playing"

        Sbar.animate("circ", 45, function()
            media_artist:set({ drawing = playing, label = { string = artist } })
            local max_len = math.max(#artist, #title)
            media_title:set({ drawing = playing, label = { string = title, align = "right" }})
            media_cover:set({ drawing = playing })
            media_cava:set({ drawing = playing })

            if playing then
                set_artwork(url)
                start_cava()
            else
                hide_popup()
                hide_cava_popup()
                stop_cava()
            end
        end)
    end)
end

local watcher = Sbar.add("item", "media.watcher", {
    drawing     = false,
    position    = "right",
    updates     = true,
    update_freq = 2,
})

watcher:subscribe("routine", refresh)
watcher:subscribe("forced", refresh)
refresh()

Sbar.add("item", "media.padding", {
    position = "right",
    width = settings.group_paddings
})
