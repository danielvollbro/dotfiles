{ config, pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
    rofi
    awww
    hyprlock
    hypridle
    papirus-icon-theme
    (pkgs.writeShellScriptBin "laptop-screen-watchdog" ''
      # Robust laptop-screen watchdog: polls every 1s. If eDP-1 is disabled
      # while NO external monitor is connected, force it back on. Also
      # restarts waybar if it crashed. Uses a lockfile so a slow-starting
      # waybar can't be mistaken for "missing" and spawn duplicates.
      #
      # NOTE: the nix-wrapped waybar binary's real process name is
      # ".waybar-wrapped", not "waybar" -- `pgrep -x waybar` never matches
      # it and causes an infinite spawn storm. Use `pgrep -f waybar`
      # (substring on full cmdline) instead.
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ | head -1)
      export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1
      HYPRCTL=${pkgs.hyprland}/bin/hyprctl
      EDP_SPEC="eDP-1,3840x2160@60,0x0,1.67"
      WAYBAR_LOCK=/tmp/waybar-watchdog.lock

      while true; do
        # Poll every 5s instead of 1s: still catches screen swaps quickly,
        # but ~80% fewer subprocess spawns keeps the CPU free to idle.
        sleep 5
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
        if ! ${pkgs.procps}/bin/pgrep -f waybar >/dev/null 2>&1; then
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
  xdg.configFile."rofi/config.rasi".source = ../home/rofi/config.rasi;
  xdg.configFile."rofi/rofi.warm.rasi".source = ../home/rofi/rofi.warm.rasi;
  xdg.configFile."hypr/hyprlock.conf".source = ../home/hypr/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ../home/hypr/hypridle.conf;
  xdg.configFile."nvim/init.lua".source = ../home/nvim/init.lua;
  xdg.configFile."nvim/after/plugins/telescope.lua".source = ../home/nvim/after/plugins/telescope.lua;
  xdg.configFile."nvim/lua/plugins/telescope.lua".source = ../home/nvim/lua/plugins/telescope.lua;
  xdg.configFile."nvim/lua/config/sets.lua".source = ../home/nvim/lua/config/sets.lua;
  xdg.configFile."nvim/lua/config/remaps.lua".source = ../home/nvim/lua/config/remaps.lua;
  xdg.configFile."nvim/lua/config/lazy.lua".source = ../home/nvim/lua/config/lazy.lua;

  # Wallpaper (used by swww + hyprlock)
  xdg.configFile."wallpapers/japan-night.jpg".source = ../home/wallpapers/japan-night.jpg;
  xdg.configFile."waybar/sysinfo.sh" = {
    source = ../home/waybar/sysinfo.sh;
    executable = true;
  };
  xdg.configFile."waybar/idle_state.sh" = {
    source = ../home/waybar/idle_state.sh;
    executable = true;
  };
}
