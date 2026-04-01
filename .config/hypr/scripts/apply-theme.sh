#!/usr/bin/env bash
set -uo pipefail

failures=()

log() {
  printf '[INFO] %s\n' "$*"
}

ok() {
  printf '[ OK ] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

fail() {
  local msg="$1"
  failures+=("$msg")
  printf '[FAIL] %s\n' "$msg" >&2
}

run_step() {
  local name="$1"
  shift

  if "$@"; then
    ok "$name"
  else
    local code=$?
    fail "$name (exit $code)"
  fi
  return 0
}

run_shell_step() {
  local name="$1"
  local cmd="$2"

  if bash -o pipefail -c "$cmd"; then
    ok "$name"
  else
    local code=$?
    fail "$name (exit $code)"
  fi
  return 0
}

copy_if_exists() {
  local src="$1"
  local dst="$2"

  if [[ -f "$src" ]]; then
    install -Dm644 "$src" "$dst"
  else
    warn "pywal missing output: $src"
    return 1
  fi
}

apply_spicetify_pywal() {
  command -v spicetify >/dev/null 2>&1 || {
    warn "spicetify not installed; skipping"
    return 0
  }

  command -v pywal-spicetify >/dev/null 2>&1 || {
    warn "pywal-spicetify not installed; skipping"
    return 0
  }

  run_step "spicetify config current_theme" spicetify config current_theme Dribbblish
  run_step "spicetify config color_scheme" spicetify config color_scheme pywal
  run_step "spicetify config inject_css" spicetify config inject_css 1
  run_step "spicetify config replace_colors" spicetify config replace_colors 1
  run_step "spicetify config inject_theme_js" spicetify config inject_theme_js 1
  run_step "spicetify config overwrite_assets" spicetify config overwrite_assets 1
  run_step "pywal-spicetify Dribbblish" pywal-spicetify Dribbblish
  run_step "spicetify apply" spicetify apply
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

main() {
  local wall=""

  if [[ $# -gt 0 ]]; then
    wall="$1"
  else
    wall="$(pick_wallpaper_rofi)" || {
      fail "wallpaper selection failed"
      wall=""
    }
  fi

  if [[ -z "${wall:-}" ]]; then
    fail "no wallpaper selected"
  fi

  run_step "create config directories" mkdir -p \
    "$HOME/.config/alacritty" \
    "$HOME/.config/waybar" \
    "$HOME/.config/eww" \
    "$HOME/.config/starship"

  if [[ -n "${wall:-}" && -f "$wall" ]]; then
    run_step "hyprpaper wallpaper" hyprctl hyprpaper wallpaper ",$wall"
    run_step "wal apply" wal -i "$wall" -q
  else
    fail "wallpaper file missing: ${wall:-<empty>}"
  fi

  apply_spicetify_pywal
  run_step "pywalfox update" pywalfox update

  run_step "copy alacritty colors" copy_if_exists \
    "$HOME/.cache/wal/alacritty.toml" \
    "$HOME/.config/alacritty/colors.toml"

  run_step "copy waybar css" copy_if_exists \
    "$HOME/.cache/wal/waybar.css" \
    "$HOME/.config/waybar/style.css"

  run_step "copy eww scss" copy_if_exists \
    "$HOME/.cache/wal/eww.scss" \
    "$HOME/.config/eww/eww.scss"

  run_step "copy starship config" copy_if_exists \
    "$HOME/.cache/wal/starship.toml" \
    "$HOME/.config/starship.toml"

  run_step "pkill waybar" pkill waybar
  run_shell_step "start waybar" 'waybar >/dev/null 2>&1 & disown'

  run_step "eww reload" eww reload
  run_step "hyprctl reload" hyprctl reload

  printf '\n'
  if ((${#failures[@]})); then
    printf 'Failed steps:\n' >&2
    printf ' - %s\n' "${failures[@]}" >&2
    return 1
  else
    printf 'All steps completed successfully.\n'
    return 0
  fi
}

main "$@"