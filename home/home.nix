{ config, pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
    (pkgs.writeShellScriptBin "kanshi-laptop-reload" ''
      # Kanshi cannot re-enable a disabled monitor on Hyprland 0.55 lua;
      # a hyprctl reload (disabled) + dpms on (black screen) is required.
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ | head -1)
      export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1
      sleep 1
      ${pkgs.hyprland}/bin/hyprctl reload
      sleep 1
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
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
