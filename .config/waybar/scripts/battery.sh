#!/usr/bin/env bash

BAT="/sys/class/power_supply"

# detect laptop
if [ -d "$BAT/BAT0" ] || [ -d "$BAT/BAT1" ]; then
    CAP=$(cat $BAT/BAT0/capacity 2>/dev/null || cat $BAT/BAT1/capacity 2>/dev/null)
    STAT=$(cat $BAT/BAT0/status 2>/dev/null || cat $BAT/BAT1/status 2>/dev/null)

    ICON=""

    if [ "$STAT" = "Charging" ]; then
        ICON="󰃨"
    fi

    echo "{\"text\":\"$CAP% $ICON\",\"tooltip\":\"$STAT - $CAP%\"}"
else
    # desktop → fully hidden
    echo '{"text":""}'
fi