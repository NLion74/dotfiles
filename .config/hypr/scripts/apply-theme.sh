#!/usr/bin/env bash
set -euo pipefail

if [ $# -gt 0 ]; then
    wall="$1"
else
    wall="$(
        while IFS= read -r -d '' f; do
            printf 'img:%s:text:%s\n' "$f" "$(basename "$f")"
        done < <(
            find "$HOME/dotfiles/data" -type f \
              \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
              -print0
        ) | wofi --dmenu \
            --prompt="Select wallpaper" \
            --allow-images \
            --image-size=160 \
            --parse-search \
        || true
    )"

    [ -z "${wall:-}" ] && exit 1

    wall="${wall#img:}"
    wall="${wall%%:text:*}"
fi

[ -z "${wall:-}" ] && exit 1

mkdir -p \
  "$HOME/.config/alacritty" \
  "$HOME/.config/waybar" \
  "$HOME/.config/eww"

if [[ -f "$wall" ]]; then
    hyprctl hyprpaper preload "$wall" || true
    hyprctl hyprpaper wallpaper ",$wall" || true
fi

wal -i "$wall" -q
pywalfox update || true

copy_if_exists() {
  local src="$1"
  local dst="$2"

  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    install -Dm644 "$src" "$dst"
  else
    printf 'pywal missing output: %s\n' "$src" >&2
  fi
}

copy_if_exists "$HOME/.cache/wal/alacritty.toml" "$HOME/.config/alacritty/colors.toml"
copy_if_exists "$HOME/.cache/wal/waybar.css"     "$HOME/.config/waybar/style.css"
copy_if_exists "$HOME/.cache/wal/eww.scss"       "$HOME/.config/eww/eww.scss"
copy_if_exists "$HOME/.cache/wal/starship.toml"  "$HOME/.config/starship.toml"

pkill waybar || true
waybar >/dev/null 2>&1 & disown

eww reload || true
hyprctl reload || true
