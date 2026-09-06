local home = os.getenv("HOME")
local generated = home .. "/.cache/wal/hyprland-colors.lua"

local f = io.open(generated, "r")
if f then
  f:close()
  dofile(generated)
else
  hl.print("conf/colors.lua: no generated pywal Lua colors file found at " .. generated)
end
