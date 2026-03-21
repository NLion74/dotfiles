#!/usr/bin/env bash
set -euo pipefail

get_vol_percent() {
  wpctl get-volume "$1" | awk '
    {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9.]+$/) {
          v = int(($i * 100) + 0.5)
          if (v > 150) v = 150
          print v
          exit
        }
      }
    }'
}

set_vol() {
  awk -v p="$1" 'BEGIN {
    if (p < 0) p = 0
    if (p > 150) p = 150
    printf "%.2f\n", p / 100
  }'
}

section_json() {
  local kind="$1"
  wpctl status | awk -v kind="$kind" '
    function esc(s) { gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s); return s }

    $0 ~ "^[[:space:]]*[├└]─ " kind ":" { in_section=1; next }

    in_section {
      if ($0 ~ "^[[:space:]]*[├└]─ " && $0 !~ kind ":") exit

      line=$0
      gsub(/^[[:space:]│]*/, "", line)

      if (match(line, /^(\*)?[[:space:]]*([0-9]+)\.\s+(.+)\s+\[vol:/, m)) {
        id=m[2]
        label=m[3]
        if (kind == "Sources" && label ~ /^Monitor of /) next
        printf "%s{\"id\":\"%s\",\"label\":\"%s\"}", (n++ ? "," : ""), id, esc(label)
      }
    }

    END { print "" }
  ' | awk 'BEGIN{printf "["} {printf "%s",$0} END{print "]"}'
}

default_id() {
  local kind="$1"
  wpctl status | awk -v kind="$kind" '
    $0 ~ "^[[:space:]]*[├└]─ " kind ":" { in_section=1; next }

    in_section {
      if ($0 ~ "^[[:space:]]*[├└]─ " && $0 !~ kind ":") exit

      line=$0
      gsub(/^[[:space:]│]*/, "", line)

      if (match(line, /^\*[[:space:]]*([0-9]+)\./, m)) {
        print m[1]
        exit
      }
    }'
}

case "${1:-}" in
  sink-vol)
    get_vol_percent @DEFAULT_SINK@
    ;;
  source-vol)
    get_vol_percent @DEFAULT_SOURCE@
    ;;
  default-sink-id)
    default_id Sinks
    ;;
  default-source-id)
    default_id Sources
    ;;
  sinks)
    section_json Sinks
    ;;
  sources)
    section_json Sources
    ;;
  set-sink)
    wpctl set-default "$2"
    ;;
  set-source)
    wpctl set-default "$2"
    ;;
  set-sink-vol)
    wpctl set-volume @DEFAULT_SINK@ "$(set_vol "$2")"
    ;;
  set-source-vol)
    wpctl set-volume @DEFAULT_SOURCE@ "$(set_vol "$2")"
    ;;
  toggle-sink-mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  toggle-source-mute)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    ;;
  sink-muted)
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo true || echo false
    ;;
  source-muted)
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo true || echo false
    ;;

  *)
    exit 1
    ;;
esac
