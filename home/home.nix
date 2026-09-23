{ config, pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
  ];

  programs.home-manager.enable = true;

  # Symlink the dotfiles in this repo into place instead of managing them by hand
  xdg.configFile."hypr/hyprland.conf".source = ../home/hypr/hyprland.conf;
  xdg.configFile."waybar/config".source = ../home/waybar/config;
  xdg.configFile."waybar/style.css".source = ../home/waybar/style.css;
  xdg.configFile."mako/config".source = ../home/mako/config;
  xdg.configFile."kanshi/config".source = ../home/kanshi/config;
}
