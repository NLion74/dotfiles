require("conf.env")
require("conf.variables")   -- exposes shared values via package cache, see conf/variables.lua
require("conf.monitors")
require("conf.input")
require("conf.general")
require("conf.decoration")
require("conf.rules")
require("conf.binds")
require("conf.autostart")

-- Pywal-generated colors.
-- NOTE: the old setup sourced ~/.cache/wal/hyprland-colors.conf, which pywal
-- regenerates (in hyprlang syntax) every time you run `apply-theme.sh`.
-- hyprlang snippets can no longer be `source`d into a Lua config, so this
-- file must be regenerated as Lua. See conf/colors.lua and the migration
-- notes in the report for how to update your pywal template.
local ok, err = pcall(require, "conf.colors")
if not ok then
  hl.print("hyprland.lua: pywal colors module not found or failed to load: " .. tostring(err))
end
