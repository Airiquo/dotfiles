local colors   = require("colors")
local settings = require("settings")

local MAX_APPS = 8

---@type table<string, WsSlot>
local slots = {}

local AEROSPACE_QUERY = [[
FOCUSED=$(aerospace list-workspaces --focused)
echo "FOCUSED|$FOCUSED"
for ws in $(aerospace list-workspaces --all); do
  APPS=$(aerospace list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null | tr '\n' ',')
  echo "WS|$ws|$APPS"
done
]]

local function name_num(ws) return "aerospace.ws." .. ws .. ".num" end
local function name_app(ws, j) return "aerospace.ws." .. ws .. ".app." .. j end
local function name_brk(ws) return "aerospace.ws." .. ws .. ".bracket" end

local function make_num(ws)
    local item = Sbar.add("item", name_num(ws), {
        icon = {
            string          = ws,
            font            = { family = settings.font.text_round, style = "Bold", size = 12.0 },
            color           = colors.grey,
            highlight_color = colors.white,
            padding_left    = 4,
            padding_right   = 4,
            y_offset        = 1,
        },
        label = { drawing = false },
    })
    item:subscribe("mouse.clicked", function()
        Sbar.exec("aerospace workspace " .. ws)
    end)
    return item
end

local function make_app(ws, j)
    return Sbar.add("item", name_app(ws, j), {
        drawing       = false,
        icon          = { drawing = false },
        label         = { drawing = false },
        padding_left  = 2,
        padding_right = 2,
        background    = {
            drawing = true,
            image   = { scale = 0.80, clip = 0.8 },
        },
    })
end

local function make_bracket(ws, members)
    return Sbar.add("bracket", name_brk(ws), members, {
        blur_radius = 12,
        background  = {
            drawing       = false,
            color         = colors.bg05,
            border_color  = colors.bg1,
            blur_radius   = 32,
            border_width  = 1,
            height        = 32,
            corner_radius = 10,
        },
    })
end

local function ensure_slot(ws)
    if slots[ws] then return slots[ws] end
    local num = make_num(ws)
    local apps = {}
    local members = { num.name }
    for j = 1, MAX_APPS do
        apps[j] = make_app(ws, j)
        members[#members + 1] = apps[j].name
    end
    local bracket = make_bracket(ws, members)
    slots[ws] = { num = num, apps = apps, bracket = bracket }
    return slots[ws]
end

local function paint_slot(ws, apps, active)
    local slot = slots[ws]
    if not slot then return end
    slot.num:set({ icon = { highlight = active } })
    for j = 1, MAX_APPS do
        local app = apps[j]
        local item = slot.apps[j]
        if app then
            item:set({
                drawing    = true,
                background = {
                    drawing     = true,
                    blur_radius = 12,
                    image       = {
                        string = "app." .. app,
                        scale  = active and 1 or 0.80,
                        clip   = 0.8,
                    },
                    x_offset    = -1,
                },
            })
        else
            item:set({ drawing = false })
        end
    end
    slot.bracket:set({ background = { drawing = active } })
end

local function hide_slot(ws)
    local slot = slots[ws]
    if not slot then return end
    for j = 1, MAX_APPS do slot.apps[j]:set({ drawing = false }) end
    slot.bracket:set({ background = { drawing = false } })
end

local function render(ws_list, ws_apps, focused)
    local seen = {}
    for _, ws in ipairs(ws_list) do
        ensure_slot(ws)
        paint_slot(ws, ws_apps[ws] or {}, ws == focused)
        seen[ws] = true
    end
    for ws, _ in pairs(slots) do
        if not seen[ws] then hide_slot(ws) end
    end
end

local function set_focus(focused)
    for ws, slot in pairs(slots) do
        local active = (ws == focused)
        slot.num:set({ icon = { highlight = active } })
        slot.bracket:set({ background = { drawing = active } })
        for j = 1, MAX_APPS do
            local item = slot.apps[j]
            if item then
                item:set({ background = { image = { scale = active and 1 or 0.80 } } })
            end
        end
    end
end

local function refresh_focus()
    Sbar.exec("aerospace list-workspaces --focused", function(out)
        if not out then return end
        set_focus((out:gsub("%s+$", "")))
    end)
end

local function refresh_full()
    Sbar.exec(AEROSPACE_QUERY, function(out)
        if not out then return end
        local focused = nil
        local ws_list = {}
        local ws_apps = {}
        for line in out:gmatch("[^\r\n]+") do
            local kind, rest = line:match("^(%a+)|(.*)$")
            if kind == "FOCUSED" then
                focused = rest:gsub("%s+$", "")
            elseif kind == "WS" then
                local ws, apps_str = rest:match("^([^|]*)|(.*)$")
                if ws and ws ~= "" then
                    table.insert(ws_list, ws)
                    local apps = {}
                    for app in (apps_str or ""):gmatch("[^,]+") do
                        table.insert(apps, app)
                    end
                    ws_apps[ws] = apps
                end
            end
        end
        render(ws_list, ws_apps, focused)
    end)
end

Sbar.exec("sketchybar --add event aerospace_workspace_change")

local watcher = Sbar.add("item", "aerospace.watcher", {
    drawing       = false,
    updates       = true,
    padding_left  = 0,
    padding_right = 0,
})

-- Cheap highlight-only flip: runs on EVERY focus/workspace change, near
-- zero cost (one CLI call, no matter how many windows/workspaces exist).
watcher:subscribe(
    { "aerospace_workspace_change", "aerospace_focus_change", "system_woke", "forced" },
    refresh_focus
)

-- Expensive full re-scan (every workspace, every window): now ONLY runs
-- on an actual workspace switch, not plain window-to-window focus moves
-- within the same workspace. This is the fix for the rapid-switching
-- thermal spike -- alt-tabbing between two already-open windows no
-- longer triggers a full re-scan of every workspace's icons.
watcher:subscribe(
    { "aerospace_workspace_change", "system_woke", "forced" },
    refresh_full
)

Sbar.delay(0.5, refresh_full)
