hl.config({
  general = {
    col = {
      active_border = {
        colors = { "rgba({color5.strip}ee)", "rgba({color13.strip}ee)" },
        angle = 45,
      },
      inactive_border       = "rgba({background.strip}99)",
      nogroup_border        = "rgba({color1.strip}dd)",
      nogroup_border_active = "rgba({color5.strip}ee)",
    },
  },

  group = {
    col = {
      border_active          = "rgba({color5.strip}ee)",
      border_inactive        = "rgba({background.strip}99)",
      border_locked_active   = "rgba({color13.strip}ee)",
      border_locked_inactive = "rgba({color1.strip}99)",
    },
    groupbar = {
      col = {
        active          = "rgba({color5.strip}ff)",
        inactive        = "rgba({background.strip}ff)",
        locked_active   = "rgba({color13.strip}ff)",
        locked_inactive = "rgba({color1.strip}ff)",
      },
    },
  },
})