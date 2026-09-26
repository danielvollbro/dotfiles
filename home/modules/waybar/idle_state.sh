#!/usr/bin/env bash
# Shows "IDLE // HOLD" while user is idle, otherwise "ACTIVE"
idle_ms=$(cat /tmp/waybar-hypridle-last 2>/dev/null || echo 0)
if hyprctl -i hyprctl_idle 2>/dev/null | grep -q true; then
  echo '{"text":"IDLE // HOLD","class":"idle"}'
else
  echo '{"text":"","class":"active"}'
fi
