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
      # or dpms-off while NO external monitor is connected, force it back on.
      # Single reload+dpms per event, with a cooldown to avoid double-firing
      # (kanshi's exec hook was unreliable and caused overlap/scale warnings
      # when it collided with a second concurrent reload).
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ | head -1)
      export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1
      HYPRCTL=${pkgs.hyprland}/bin/hyprctl

      while true; do
        sleep 1
        ext_connected=0
        for c in /sys/class/drm/card*-DP-*/status; do
          [ "$(cat "$c" 2>/dev/null)" = "connected" ] && ext_connected=1
        done
        if [ "$ext_connected" = "0" ]; then
          edp_disabled=$($HYPRCTL monitors all 2>/dev/null | awk '/Monitor eDP-1/{f=1} f&&/disabled:/{print $2; exit}')
          if [ "$edp_disabled" = "true" ]; then
            $HYPRCTL reload
            sleep 0.5
            $HYPRCTL dispatch dpms on
            sleep 5
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
