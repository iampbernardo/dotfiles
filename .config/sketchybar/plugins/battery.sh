#!/usr/bin/env bash

GREEN="0xff9ece6a"
YELLOW="0xffe0af68"
RED="0xfff7768e"

PERCENTAGE="$(pmset -g batt | grep -Eo '\d+%' | head -1 | tr -d '%')"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

if [ "$PERCENTAGE" -le 20 ]; then
  ICON=""
  COLOR=$RED
elif [ "$PERCENTAGE" -le 60 ]; then
  ICON=""
  COLOR=$YELLOW
else
  ICON=""
  COLOR=$GREEN
fi

if [ -n "$CHARGING" ]; then
  ICON=""
  COLOR=$GREEN
fi

sketchybar --set battery icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
