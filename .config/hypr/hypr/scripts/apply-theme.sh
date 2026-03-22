#!/usr/bin/env bash
set -euo pipefail

if [ $# -gt 0 ]; then
    wall="$1"
else
    wall="$(find "$HOME/dotfiles/data" -type f \( -name "*.jpg" -o -name "*.png" \) \
        | wofi --dmenu --prompt="Select wallpaper" || true)"
fi

[ -z "$wall" ] && exit 1

mkdir -p \
  "$HOME/.config/alacritty" \
  "$HOME/.config/waybar" \
  "$HOME/.config/eww" \
  "$HOME/.config/gtk-3.0"

if pgrep -x hyprpaper >/dev/null; then
  hyprctl hyprpaper preload "$wall" || true
  hyprctl hyprpaper wallpaper ",$wall" || true
fi

wal -i "$wall" -q

[ -f "$HOME/.cache/wal/colors.sh" ] && source "$HOME/.cache/wal/colors.sh"

pywalfox update

cp -f "$HOME/.cache/wal/colors-alacritty" "$HOME/.config/alacritty/colors.yml" 2>/dev/null || true
cp -f "$HOME/.cache/wal/waybar.css" "$HOME/.config/waybar/style.css" 2>/dev/null || true
cp -f "$HOME/.cache/wal/eww.scss" "$HOME/.config/eww/eww.scss" 2>/dev/null || true

cp -f "$HOME/.cache/wal/00-gtk-theme.json" "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null || true
cp -f "$HOME/.cache/wal/gtk.css" "$HOME/.config/gtk-3.0/gtk.css" 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'Wal' || true

cp -f "$HOME/.cache/wal/colors-starship.toml" "$HOME/.config/starship/palette.toml" 2>/dev/null || true

pkill waybar || true
waybar & disown

eww reload || true
hyprctl reload || true