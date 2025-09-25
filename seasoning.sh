#!/usr/bin/env bash
# usage:
#   seasoning.sh --timeofday [--south] [--output NAME]
#   seasoning.sh --season    [--south] [--output NAME]
#   seasoning.sh --toggle                [--output NAME]   # flips both modules together (per monitor)

hemisphere="north"
mode=""           # timeofday | season
toggle=false
out=""            # monitor name

# ---- args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --south) hemisphere="south"; shift ;;
    --timeofday|--season) mode="${1#--}"; shift ;;
    --toggle) toggle=true; shift ;;
    --output) out="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# ---- state path (per monitor) ----
base="$HOME/.cache/waybar"; mkdir -p "$base"
out="${out:-${WAYBAR_OUTPUT_NAME:-all}}"
state="$base/seasoning-alt-$out"    # single toggle for both L/R on this monitor

# ---- toggle only? ----
if $toggle; then
  cur=$(cat "$state" 2>/dev/null || echo 0)
  echo $((1-cur)) > "$state"
  exit 0
fi

# ---- read toggle ----
alt=$(cat "$state" 2>/dev/null || echo 0)

# ---- date/time ----
weekday=$(date +%A); weekday="${weekday,}"
hour=$((10#$(date +%H)))
month=$((10#$(date +%m)))
year=$((10#$(date +%Y))); year=$((year + 10000))  # Holocene

# Seasons: Dec–Feb winter; phase shifted so Dec=early winter
season_index=$(((month + 1) / 3 % 4))
phase_index=$(((month + 1) % 3))
[[ $hemisphere == "south" ]] && season_index=$(((season_index + 2) % 4))
seasons=(winter spring summer autumn)
phases=("early " "mid" "late ")
season=${seasons[$season_index]}
season_phase=${phases[$phase_index]}

# Time of day
times=(night morning afternoon evening)
tod_index=$(( hour / 6 ))
timeofday=${times[$tod_index]}

# ---- output ----
case "$mode" in
  timeofday)
    if ((alt)); then date +'%B %d'; else echo "$weekday $timeofday"; fi
    ;;
  season)
    if ((alt)); then date +'%Z week %V %m-%Y'; else echo "$season_phase$season $year"; fi
    ;;
  *)
    echo "error: specify --timeofday or --season" >&2; exit 1
    ;;
esac
