#!/usr/bin/env bash

WALL="~/sddm-astronaut-theme/Backgrounds/pixel_sakura_static.png"

pkill hyprpaper 2>/dev/null
hyprpaper &

sleep 1

hyprctl hyprpaper preload "$WALL"
for m in $(hyprctl monitors | grep '^Monitor' | awk '{print $2}'); do
  hyprctl hyprpaper wallpaper "$m,$WALL"
done
hyprctl hyprpaper unload unused
