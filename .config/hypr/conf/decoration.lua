-- ~/.config/hypr/conf/decoration.lua
-- Migrated from decoration-8.conf

hl.config({
  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.96,
    dim_inactive = true,
    dim_strength = 0.04,

    shadow = {
      enabled = true,
      range = 12,
      render_power = 3,
      color = "rgba(1a1028aa)",
    },
  },

  animations = {
    enabled = true,
  },
})

-- Custom bezier curve ("soft" in the old config)
hl.curve("soft", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })

-- Animation leaves (name, enabled, speed, curve, style)
hl.animation({ leaf = "windows",    enabled = true, speed = 7, bezier = "soft",    style = "slide" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 7, bezier = "soft",    style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 6, bezier = "soft",    style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "default", style = "slidefade" })
