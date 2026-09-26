#!/usr/bin/env bash
# HUD-style CPU/MEM readout for waybar
cpu=$(top -bn1 | awk '/Cpu\(s\)/{printf "%d", $2}')
read -r memused memtotal <<< "$(free -m | awk '/Mem:/{printf "%s %s", $3, $2}')"
printf "CPU %03d%%  MEM %s/%sG" "$cpu" "$(awk "BEGIN{printf \"%.1f\", $memused/1024}")" "$(awk "BEGIN{printf \"%.0f\", $memtotal/1024}")"
