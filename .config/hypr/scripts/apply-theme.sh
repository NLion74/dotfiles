#!/usr/bin/env bash
set -euo pipefail

get_spotify_state() {
  TRACK_ID=$(dbus-send --print-reply \
    --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2.Player.Metadata \
    | grep -A 1 "spotify:track" | tail -n1 | awk -F '"' '{print $2}')

  POSITION=$(dbus-send --print-reply \
    --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2.Player.Position \
    | grep int64 | awk '{print $2}')

  echo "$TRACK_ID|$POSITION"
}

restore_spotify_state() {
  IFS="|" read -r TRACK_ID POSITION <<< "$1"

  [ -z "$TRACK_ID" ] && return

  dbus-send --print-reply \
    --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2.Player.OpenUri \
    string:"$TRACK_ID" >/dev/null

  sleep 1

  dbus-send --print-reply \
    --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2.Player.Seek \
    int64:"$POSITION" >/dev/null
}

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

apply_spicetify_pywal() {
  command -v spicetify >/dev/null 2>&1 || return 0
  command -v pywal-spicetify >/dev/null 2>&1 || return 0

  STATE=$(get_spotify_state)

  spicetify config current_theme Dribbblish >/dev/null
  spicetify config color_scheme pywal >/dev/null
  spicetify config inject_css 1 >/dev/null
  spicetify config replace_colors 1 >/dev/null
  spicetify config inject_theme_js 1 >/dev/null
  spicetify config overwrite_assets 1 >/dev/null

  pywal-spicetify Dribbblish
  spicetify apply

  sleep 2
  restore_spotify_state "$STATE"
}

pick_wallpaper_rofi() {
  local f

  find "$HOME/dotfiles/data" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 |
    while IFS= read -r -d '' f; do
      printf '%s\0display\x1f%s\x1ficon\x1fthumbnail://%s\n' \
        "$f" "$(basename "$f")" "$f"
    done |
    rofi -dmenu -i -no-custom -show-icons \
      -p "Select wallpaper" \
      -theme-str '
        window { width: 34%; }
        listview { lines: 10; columns: 1; spacing: 4px; }
        element { padding: 4px; }
        element-icon { size: 3em; }
      '
}

if [ $# -gt 0 ]; then
  wall="$1"
else
  wall="$(pick_wallpaper_rofi || true)"
  [ -z "${wall:-}" ] && exit 1
fi

[ -z "${wall:-}" ] && exit 1

mkdir -p \
  "$HOME/.config/alacritty" \
  "$HOME/.config/waybar" \
  "$HOME/.config/eww" \
  "$HOME/.config/starship"

if [[ -f "$wall" ]]; then
  hyprctl hyprpaper preload "$wall" || true
  hyprctl hyprpaper wallpaper ",$wall" || true
fi

wal -i "$wall" -q

apply_spicetify_pywal
pywalfox update || true

copy_if_exists "$HOME/.cache/wal/alacritty.toml" "$HOME/.config/alacritty/colors.toml"
copy_if_exists "$HOME/.cache/wal/waybar.css"     "$HOME/.config/waybar/style.css"
copy_if_exists "$HOME/.cache/wal/eww.scss"       "$HOME/.config/eww/eww.scss"
copy_if_exists "$HOME/.cache/wal/starship.toml"  "$HOME/.config/starship.toml"

pkill waybar || true
waybar >/dev/null 2>&1 & disown

eww reload || true
hyprctl reload || true