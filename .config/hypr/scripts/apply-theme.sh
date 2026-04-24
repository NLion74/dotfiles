#!/usr/bin/env bash
# apply-theme.sh — generate and apply a pywal theme from a wallpaper
#
# Usage:
#   apply-theme.sh              pick wallpaper via rofi
#   apply-theme.sh --current    regenerate from last-used wallpaper
#   apply-theme.sh /path/img    apply an explicit wallpaper path
set -uo pipefail

# ── State ─────────────────────────────────────────────────────────────────────

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/apply-theme"
STATE_FILE="$STATE_DIR/current-wallpaper"

WALLPAPER_DIR="$HOME/dotfiles/data"
SPICETIFY_THEME="Sleek"

# ── Logging ───────────────────────────────────────────────────────────────────

failures=()

log()  { printf '[INFO] %s\n' "$*"; }
ok()   { printf '[ OK ] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
fail() { failures+=("$1"); printf '[FAIL] %s\n' "$1" >&2; }

run_step() {
  local name="$1"; shift
  if "$@"; then
    ok "$name"
  else
    fail "$name (exit $?)"
  fi
  return 0
}

run_shell_step() {
  local name="$1" cmd="$2"
  if bash -o pipefail -c "$cmd"; then
    ok "$name"
  else
    fail "$name (exit $?)"
  fi
  return 0
}

# ── Helpers ───────────────────────────────────────────────────────────────────

copy_if_exists() {
  local src="$1" dst="$2"
  if [[ -f "$src" ]]; then
    install -Dm644 "$src" "$dst"
  else
    warn "pywal did not produce: $src"
    return 1
  fi
}

save_wallpaper() {
  local wall="$1"
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$wall" > "$STATE_FILE"
}

get_saved_wallpaper() {
  [[ -f "$STATE_FILE" ]] || return 1
  local wall
  wall="$(<"$STATE_FILE")"
  [[ -n "$wall" && -f "$wall" ]] || return 1
  printf '%s\n' "$wall"
}

# ── Wallpaper selection ───────────────────────────────────────────────────────

pick_wallpaper_rofi() {
  local f
  find "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -print0 |
    while IFS= read -r -d '' f; do
      printf '%s\0display\x1f%s\x1ficon\x1fthumbnail://%s\n' \
        "$f" "$(basename "$f")" "$f"
    done |
    rofi -dmenu -i -no-custom -show-icons \
      -p "Select wallpaper" \
      -theme-str '
        window   { width: 34%; }
        listview { lines: 10; columns: 1; spacing: 4px; }
        element  { padding: 4px; }
        element-icon { size: 3em; }
      '
}

# ── Theme application steps ───────────────────────────────────────────────────
apply_wallpaper() {
  local wall="$1"

  hyprctl hyprpaper preload "$wall"
  hyprctl hyprpaper wallpaper ",$wall"
  hyprctl hyprpaper unload unused
}

apply_wal() {
  local wall="$1"
  run_step "wal generate" wal -i "$wall" -q
}

sync_gtk4() {
  mkdir -p "$HOME/.config/gtk-4.0"
  [[ -f "$HOME/.cache/wal/gtk4-colors.css" ]] || {
    warn "pywal did not produce gtk4-colors.css; skipping GTK4 sync"
    return 1
  }
  ln -sf "$HOME/.cache/wal/gtk4-colors.css" "$HOME/.config/gtk-4.0/colors.css"
  printf '@import url("colors.css");\n' > "$HOME/.config/gtk-4.0/gtk.css"
}

set_dark_mode() {
  command -v gsettings >/dev/null 2>&1 || { warn "gsettings not found; skipping"; return 0; }
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}

reload_nautilus() {
  command -v nautilus >/dev/null 2>&1 || return 0
  nautilus -q 2>/dev/null || true
}

apply_spicetify() {
  local src="$HOME/.cache/wal/spicetify.ini"
  local dst="${XDG_CONFIG_HOME:-$HOME/.config}/spicetify/Themes/$SPICETIFY_THEME/color.ini"

  command -v spicetify >/dev/null 2>&1 || { warn "spicetify not found; skipping"; return 0; }
  [[ -f "$src" ]] || { warn "pywal did not produce spicetify.ini; skipping"; return 1; }

  run_step "spicetify: copy color.ini"       copy_if_exists "$src" "$dst"
  run_step "spicetify: set theme"            spicetify config current_theme "$SPICETIFY_THEME"
  run_step "spicetify: set color_scheme"     spicetify config color_scheme pywal
  run_step "spicetify: inject_css"           spicetify config inject_css 1
  run_step "spicetify: replace_colors"       spicetify config replace_colors 1
  run_step "spicetify: inject_theme_js"      spicetify config inject_theme_js 1
  run_step "spicetify: overwrite_assets"     spicetify config overwrite_assets 1
  run_step "spicetify: apply"                spicetify apply --no-restart
}

copy_pywal_outputs() {
  local cache="$HOME/.cache/wal"
  run_step "alacritty colors" copy_if_exists "$cache/alacritty.toml" "$HOME/.config/alacritty/colors.toml"
  run_step "waybar css"       copy_if_exists "$cache/waybar.css"     "$HOME/.config/waybar/style.css"
  run_step "eww scss"         copy_if_exists "$cache/eww.scss"       "$HOME/.config/eww/eww.scss"
  run_step "starship config"  copy_if_exists "$cache/starship.toml"  "$HOME/.config/starship.toml"
}

restart_waybar() {
  # pkill is non-fatal: waybar may not be running on first boot
  pkill waybar 2>/dev/null || true
  run_shell_step "waybar start" 'waybar >/dev/null 2>&1 & disown'
}

reload_eww() {
  command -v eww >/dev/null 2>&1 || { warn "eww not found; skipping"; return 0; }
  # Reload config, then open the bar — both are soft failures
  eww reload 2>/dev/null || warn "eww reload failed (config may have errors)"
  eww open bar 2>/dev/null || warn "eww open bar failed (window 'bar' may not exist yet)"
  return 0
}

# ── Entry point ───────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage:
  apply-theme.sh              pick wallpaper via rofi
  apply-theme.sh --current    regenerate theme from last-used wallpaper
  apply-theme.sh /path/img    apply an explicit wallpaper file
  apply-theme.sh -h           show this help
EOF
}

main() {
  local wall="" mode="pick"

  case "${1:-}" in
    "")           mode="pick" ;;
    --current|-c) mode="current" ;;
    --help|-h)    usage; return 0 ;;
    -*)           warn "Unknown option: $1"; usage; return 1 ;;
    *)            wall="$1"; mode="path" ;;
  esac

  case "$mode" in
    pick)
      wall="$(pick_wallpaper_rofi)" || { fail "wallpaper selection cancelled"; wall=""; }
      ;;
    current)
      wall="$(get_saved_wallpaper)" || { fail "no saved wallpaper found (run without --current first)"; wall=""; }
      [[ -n "$wall" ]] && log "Regenerating theme from: $wall"
      ;;
    path)
      [[ -f "$wall" ]] || { fail "wallpaper file not found: $wall"; wall=""; }
      ;;
  esac

  [[ -n "$wall" ]] || { fail "no wallpaper selected"; }

  # Ensure config dirs exist
  mkdir -p \
    "$HOME/.config/alacritty" \
    "$HOME/.config/waybar" \
    "$HOME/.config/eww" \
    "$HOME/.config/starship" \
    "$HOME/.config/gtk-4.0"

  if [[ -n "$wall" && -f "$wall" ]]; then
    [[ "$mode" != "current" ]] && apply_wallpaper "$wall"
    apply_wal "$wall"
    run_step "save wallpaper state" save_wallpaper "$wall"
    run_step "sync GTK4 colors"    sync_gtk4
    run_step "libadwaita dark"     set_dark_mode
    run_step "reload nautilus"     reload_nautilus
  else
    fail "wallpaper file missing: ${wall:-<empty>}"
  fi

  apply_spicetify
  run_step "pywalfox update" pywalfox update
  copy_pywal_outputs
  restart_waybar
  reload_eww
  run_step "hyprctl reload" hyprctl reload

  printf '\n'
  if ((${#failures[@]})); then
    printf 'Failed steps (%d):\n' "${#failures[@]}" >&2
    printf '  - %s\n' "${failures[@]}" >&2
    return 1
  fi

  printf 'All steps completed successfully.\n'
}

main "$@"
