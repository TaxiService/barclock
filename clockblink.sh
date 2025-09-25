#!/usr/bin/env bash
# Modes:
# 0 HM      (blink H:M)
# 1 HM      (static)
# 2 H:M:S   (blink both colons)
# 3 H:M:S   (blink M:S only)
# 4 H:M:S   (static)
base="$HOME/.cache/waybar"
mkdir -p "$base"

# top: parse args
global=false; out=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) out="$2"; shift 2 ;;
    --global) global=true; shift ;;
    *) shift ;;
  esac
done
out="${out:-${WAYBAR_OUTPUT_NAME:-default}}"
state_local="$base/clock-mode-$out"
state_global="$base/clock-mode-all"

# pick mode: prefer per-output, else global, else 0
if [[ -f "$state_local" ]]; then mode=$(<"$state_local")
elif [[ -f "$state_global" ]]; then mode=$(<"$state_global")
else mode=0; fi

H=$(date +%H); M=$(date +%M); S=$(date +%S)
sec=$((10#$S)); blink=$((sec % 2))   # 1 on odd seconds

colon() { (( $1 )) && printf ":" || printf "."; }

case "$mode" in
  0) printf "%s" "$H"; colon "$blink"; printf "%s\n" "$M" ;;
  1) printf "%s:%s\n" "$H" "$M" ;;
  2) printf "%s" "$H"; colon "$blink"; printf "%s" "$M"; colon "$blink"; printf "%s\n" "$S" ;;
  3) printf "%s:%s" "$H" "$M"; colon "$blink"; printf "%s\n" "$S" ;;
  4) printf "%s:%s:%s\n" "$H" "$M" "$S" ;;
  *) printf "%s:%s:%s\n" "$H" "$M" "$S" ;;
esac
