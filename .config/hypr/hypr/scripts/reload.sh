
#!/usr/bin/env bash

LOG_DIR="/tmp/hypr-reload"
mkdir -p "$LOG_DIR"

echo "==> Reloading Hyprland ecosystem..."

echo "-> Stopping processes..."
pkill waybar
pkill eww
pkill hyprpaper
pkill hyprsunset

sleep 0.5

echo "-> Reloading Hyprland config..."
hyprctl reload

echo "-> Starting hyprpaper..."
hyprpaper >"$LOG_DIR/hyprpaper.log" 2>&1 &

sleep 0.2

echo "-> Starting eww..."
eww daemon
eww open bar >"$LOG_DIR/eww.log" 2>&1 &

sleep 0.2

echo "-> Starting waybar..."
waybar >"$LOG_DIR/waybar.log" 2>&1 &

sleep 0.2

echo "-> Starting hyprsunset..."
hyprsunset >"$LOG_DIR/hyprsunset.log" 2>&1 &
