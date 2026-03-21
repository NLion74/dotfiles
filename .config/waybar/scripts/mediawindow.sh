#!/usr/bin/env bash

spotify_status=$(playerctl --player=spotify status 2>/dev/null || true)

if [ "$spotify_status" = "Playing" ]; then
    track=$(playerctl --player=spotify metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)
    jq -cn \
        --arg text " $track" \
        --arg tooltip "Spotify: $track" \
        --arg class "spotify" \
        '{text: $text, tooltip: $tooltip, class: $class}'
    exit 0
fi

title=$(hyprctl -j activewindow | jq -r '.title // ""')

if [ -n "$title" ]; then
    jq -cn \
        --arg text "$title" \
        --arg tooltip "$title" \
        --arg class "window" \
        '{text: $text, tooltip: $tooltip, class: $class}'
else
    jq -cn \
        --arg text "" \
        --arg tooltip "" \
        --arg class "empty" \
        '{text: $text, tooltip: $tooltip, class: $class}'
fi
