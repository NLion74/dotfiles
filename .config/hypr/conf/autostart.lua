hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --all")

  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("bash -c 'sleep 1 && ~/.config/hypr/scripts/apply-theme.sh --current'")

  hl.exec_cmd("waybar")

  hl.exec_cmd("hyprsunset")
  hl.exec_cmd("hypridle")

  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  hl.exec_cmd("~/.config/hypr/scripts/ws-history.sh daemon")

  hl.exec_cmd("pywalfox start")

  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)
