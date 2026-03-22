#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-ws-history"
mkdir -p "$STATE_DIR"

hist_file()   { echo "$STATE_DIR/$1.history"; }
cursor_file() { echo "$STATE_DIR/$1.cursor"; }
ignore_file() { echo "$STATE_DIR/$1.ignore"; }

monitors() {
  hyprctl -j monitors | jq -r '.[].name'
}

focused_monitor() {
  hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name'
}

active_ws() {
  local mon="$1"
  hyprctl -j monitors | jq -r --arg mon "$mon" '.[] | select(.name == $mon) | .activeWorkspace.id'
}

trim_hist() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  tail -n 200 "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

append_hist() {
  local mon="$1"
  local ws="$2"
  local f
  f="$(hist_file "$mon")"
  touch "$f"

  local last=""
  if [[ -s "$f" ]]; then
    last="$(tail -n1 "$f")"
  fi

  [[ "$last" == "$ws" ]] && return 0

  printf '%s\n' "$ws" >> "$f"
  trim_hist "$f"

  rm -f "$(cursor_file "$mon")"
}

record_state() {
  local mon ws ig expected

  while IFS= read -r mon; do
    ws="$(active_ws "$mon")"
    [[ -n "$ws" && "$ws" != "null" ]] || continue

    ig="$(ignore_file "$mon")"
    if [[ -f "$ig" ]]; then
      expected="$(cat "$ig")"
      if [[ "$expected" == "$ws" ]]; then
        rm -f "$ig"
        continue
      fi
      rm -f "$ig"
    fi

    append_hist "$mon" "$ws"
  done < <(monitors)
}

next_back_target() {
  local mon="$1"
  local f c current idx next i

  f="$(hist_file "$mon")"
  [[ -f "$f" ]] || return 1

  mapfile -t H < "$f"
  (( ${#H[@]} >= 2 )) || return 1

  current="$(active_ws "$mon")"
  c="$(cursor_file "$mon")"

  if [[ -f "$c" ]]; then
    idx="$(<"$c")"
  else
    idx=-1
    for ((i=${#H[@]}-1; i>=0; i--)); do
      if [[ "${H[$i]}" == "$current" ]]; then
        idx=$i
        break
      fi
    done
    if (( idx < 0 )); then
      idx=${#H[@]}
    fi
  fi

  next=$((idx - 1))
  while (( next >= 0 )); do
    if [[ "${H[$next]}" != "$current" ]]; then
      printf '%s\n' "${H[$next]}"
      printf '%s\n' "$next" > "$c"
      return 0
    fi
    next=$((next - 1))
  done

  return 1
}

go_back() {
  local mon target
  mon="$(focused_monitor)"
  target="$(next_back_target "$mon")" || exit 0

  printf '%s\n' "$target" > "$(ignore_file "$mon")"
  hyprctl dispatch workspace "$target" >/dev/null
}

move_back_silent() {
  local mon target
  mon="$(focused_monitor)"
  target="$(next_back_target "$mon")" || exit 0

  hyprctl dispatch movetoworkspacesilent "$target" >/dev/null
}

move_back_follow() {
  local mon target
  mon="$(focused_monitor)"
  target="$(next_back_target "$mon")" || exit 0

  printf '%s\n' "$target" > "$(ignore_file "$mon")"
  hyprctl dispatch movetoworkspace "$target" >/dev/null
}

reset_state() {
  rm -f "$STATE_DIR"/*.cursor "$STATE_DIR"/*.ignore
}

daemon() {
  record_state

  local sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

  socat -U - UNIX-CONNECT:"$sock" | while IFS= read -r line; do
    case "$line" in
      workspacev2*|focusedmonv2*|moveworkspacev2*)
        record_state
        ;;
    esac
  done
}

case "${1:-}" in
  daemon) daemon ;;
  back) go_back ;;
  move-back) move_back_silent ;;
  move-back-follow) move_back_follow ;;
  reset) reset_state ;;
  *)
    echo "usage: $0 {daemon|back|move-back|move-back-follow|reset}" >&2
    exit 1
    ;;
esac
