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

  # Play track
  dbus-send --print-reply \
    --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2.Player.OpenUri \
    string:"$TRACK_ID" >/dev/null

  sleep 1

  # Seek (microseconds → milliseconds)
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

ensure_spicetify_pywal_theme() {
  local theme_dir="$HOME/.config/spicetify/Themes/pywal"

  mkdir -p "$theme_dir"

  if [[ ! -f "$theme_dir/user.css" ]]; then
    cat > "$theme_dir/user.css" <<'EOF'
/* bootstrap file for pywal spicetify theme */
EOF
  fi

  if [[ ! -f "$theme_dir/color.ini" ]]; then
    cat > "$theme_dir/color.ini" <<'EOF'
[pywal]
text               = FFFFFF
subtext            = B3B3B3
main               = 121212
sidebar            = 000000
player             = 181818
card               = 282828
shadow             = 000000
selected-row       = 1DB954
button             = 1DB954
button-active      = 1ED760
button-disabled    = 535353
tab-active         = 333333
notification       = 4687D6
notification-error = E22134
misc               = 7F7F7F
EOF
  fi
}

apply_spicetify_pywal() {
  command -v spicetify >/dev/null 2>&1 || return 0
  command -v pywal-spicetify >/dev/null 2>&1 || return 0

  ensure_spicetify_pywal_theme

  STATE=$(get_spotify_state)

  spicetify config current_theme pywal >/dev/null
  spicetify config color_scheme pywal >/dev/null
  pywal-spicetify pywal
  spicetify apply

  sleep 2
  restore_spotify_state "$STATE"
}

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