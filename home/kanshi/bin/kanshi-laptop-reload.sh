#!/run/current-system/sw/bin/sh
# Kanshi kan inte ateraktivera en disabled monitor i Hyprland lua (0.55) - kraver hyprctl reload
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ | head -1)
export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1
sleep 1
hyprctl reload
