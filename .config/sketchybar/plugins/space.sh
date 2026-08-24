#!/usr/bin/env bash
SID="$1"

BLUE="0xff7aa2f7"
MUTED="0xff565f89"
BG_ACTIVE="0xff364a82"

FOCUSED=$(aerospace list-workspaces --focused)

if [ "$FOCUSED" = "$SID" ]; then
  sketchybar --set space.$SID background.drawing=on \
                            background.color=$BG_ACTIVE \
                            label.color=$BLUE
else
  sketchybar --set space.$SID background.drawing=off \
                            label.color=$MUTED
fi
