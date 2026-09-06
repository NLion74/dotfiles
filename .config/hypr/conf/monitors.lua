-- Laptop
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

-- Desktop
hl.monitor({ output = "DP-3", mode = "preferred", position = "auto-left", scale = 1 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1.25 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "auto-right", scale = 1 })

-- Fallback rule for any other/unlisted monitor (was `monitor = , preferred, auto-right, 1`)
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })
