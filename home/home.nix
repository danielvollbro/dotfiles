{ config, pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
    (pkgs.writeShellScriptBin "laptop-screen-watchdog" ''
      # Robust laptop-screen watchdog: polls every 1s. If eDP-1 is disabled
      # while NO external monitor is connected, force it back on. Also
      # restarts waybar if it crashed. Uses a lockfile so a slow-starting
      # waybar can't be mistaken for "missing" and spawn duplicates.
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ | head -1)
      export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1
      HYPRCTL=${pkgs.hyprland}/bin/hyprctl
      EDP_SPEC="eDP-1,3840x2160@60,0x0,1.67"
      WAYBAR_LOCK=/tmp/waybar-watchdog.lock

      while true; do
        sleep 1
        ext_connected=0
        for c in /sys/class/drm/card*-DP-*/status; do
          [ "$(cat "$c" 2>/dev/null)" = "connected" ] && ext_connected=1
        done
        if [ "$ext_connected" = "0" ]; then
          edp_disabled=$($HYPRCTL monitors all 2>/dev/null | awk '/Monitor eDP-1/{f=1} f&&/disabled:/{print $2; exit}')
          if [ "$edp_disabled" = "true" ]; then
            $HYPRCTL keyword monitor "$EDP_SPEC"
            sleep 0.5
            $HYPRCTL dispatch dpms on
            sleep 5
          fi
        fi
        if ! ${pkgs.procps}/bin/pgrep -x waybar >/dev/null 2>&1; then
          if mkdir "$WAYBAR_LOCK" 2>/dev/null; then
            ${pkgs.waybar}/bin/waybar >/tmp/waybar.log 2>&1 &
            sleep 4
            rmdir "$WAYBAR_LOCK" 2>/dev/null
          fi
        fi
      done
    '')
  ];

  programs.home-manager.enable = true;

  # Symlink the dotfiles in this repo into place instead of managing them by hand
  xdg.configFile."hypr/hyprland.conf".source = ../home/hypr/hyprland.conf;
  xdg.configFile."waybar/config".source = ../home/waybar/config;
  xdg.configFile."waybar/style.css".source = ../home/waybar/style.css;
  xdg.configFile."mako/config".source = ../home/mako/config;
  xdg.configFile."kanshi/config".source = ../home/kanshi/config;
}
