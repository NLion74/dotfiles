local mod = require("conf.variables").mod

-- Launcher + apps
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("alacritty"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + F", hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/reload.sh"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/apply-theme.sh"))
hl.bind(mod .. " + Tab", hl.dsp.exec_cmd("~/.config/hypr/scripts/app-switcher.sh"))

-- Lock Hyprland
hl.bind(mod .. " + X", hl.dsp.exec_cmd("hyprlock"))

-- Clipboard manager
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd(
  "rofi -modi \"clipboard:/home/nlion/.config/hypr/scripts/cliphist-rofi-img.sh\" -show clipboard -show-icons " ..
  "-theme-str 'element { orientation: horizontal; children: [element-icon, element-text]; spacing: 6px; } " ..
  "element-icon { size: 2.2em; } listview { lines: 10; spacing: 4px; }'"
))

-- Screenshots
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mod .. " + CTRL + S", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))

-- Emoji selector
hl.bind(mod .. " + period", hl.dsp.exec_cmd("rofimoji --action type --typer wtype"))

-- Window handling
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize submap (was: bind = $mod, R, submap, resize / submap = resize ... submap = reset)
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  hl.bind("right", hl.dsp.window.resize({ x = 30, y = -1 }), { repeating = true })
  hl.bind("left", hl.dsp.window.resize({ x = -30, y = 0 }), { repeating = true })
  hl.bind("up", hl.dsp.window.resize({ x = 0, y = -30 }), { repeating = true })
  hl.bind("down", hl.dsp.window.resize({ x = 0, y = 30 }), { repeating = true })
  hl.bind("Escape", hl.dsp.submap("default"))
end)

-- Workspaces 1-10
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Global workspace navigation
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "r+0" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mod .. " + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mod .. " + left", hl.dsp.focus({ workspace = "r-1" }))

-- Local workspace navigation on the current monitor
hl.bind(mod .. " + SHIFT + right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + SHIFT + left", hl.dsp.focus({ workspace = "m-1" }))

-- Move windows
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Jump to next empty workspace on the current monitor
hl.bind(mod .. " + N", hl.dsp.focus({ workspace = "emptynm" }))

-- Send active window to next empty workspace on the current monitor
hl.bind(mod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "emptynm" }))

-- Jump to previous workspace (custom script-based history)
hl.bind(mod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/ws-history.sh back"))

-- Jump to previous workspace and follow it
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/ws-history.sh move-back-follow"))

-- Media keys
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })
