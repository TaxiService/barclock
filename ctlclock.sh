#!/usr/bin/env bash
# usage: ctlclock cycle [OUTPUT] | set [OUTPUT] N | prev [OUTPUT]
base="$HOME/.cache/waybar"; mkdir -p "$base"

action="$1"; out="$2"; param="$3"
state="$base/clock-mode-${out:-all}"   # ← single file, not a dir

mode=$(cat "$state" 2>/dev/null || echo 0)
case "$action" in
  cycle) mode=$(((mode+1)%5)) ;;
  prev)  mode=$(((mode+4)%5)) ;;
  set)   mode="$param" ;;
esac
echo "$mode" > "$state"
