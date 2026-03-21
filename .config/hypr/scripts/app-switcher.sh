#!/usr/bin/env bash

current_ws="$(hyprctl activeworkspace -j | jq -r '.id')"

choice="$(
  hyprctl clients -j |
  jq -r '
    map(select(.mapped == true)) |
    .[] |
    "\(.address)\t\(.class)\t\(.title)\t[ws:\(.workspace.id)]"
  ' |
  wofi --dmenu --prompt "Switch app"
)"

[ -z "$choice" ] && exit 0

addr="$(printf '%s\n' "$choice" | cut -f1)"

hyprctl --batch "
  dispatch movetoworkspacesilent ${current_ws},address:${addr};
  dispatch focuswindow address:${addr}
"
