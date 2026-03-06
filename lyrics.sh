#!/usr/bin/env bash

lyrics="{root of mpd library}$(mpc current -f %file% | sed 's/m4a/lrc/')"
time="$(mpc status | cut -d '/' -f 2 | head -n 2 | tail -n 1 | cut -d ' ' -f 4)"

if [[ -z "$lyrics" || -z "$time" ]]; then
  echo "You done messed up!"
  exit 1
fi
if [[ $(mpc status | head -n 2 | tail -n 1 | cut -d ' ' -f 1) == "[paused]" ]]; then
  exit
fi
# Convert target time to milliseconds
IFS=':' read -r tmin tsec <<<"$time"
target_ms=$((10#$tmin * 60000 + 10#$tsec * 1000))

last_line=""

while IFS= read -r line; do
  if [[ $line =~ \[([0-9]+):([0-9]+).([0-9]+)\] ]]; then
    min=${BASH_REMATCH[1]}
    sec=${BASH_REMATCH[2]}
    ms=${BASH_REMATCH[3]}

    total_ms=$((10#$min * 60000 + 10#$sec * 1000 + 10#$ms))

    if ((total_ms <= target_ms)); then
      last_line="$line"
    else
      break
    fi
  fi
done <"$lyrics"

if [[ -n "$last_line" ]]; then
  echo "$last_line"
fi
