{ pkgs, ... }:

{
  imports = [
    ../../modules/hyprland/default.nix
    ../../modules/rofi/default.nix
    ../../modules/mako/default.nix
    ../../modules/kanshi/default.nix
    ../../modules/waybar/default.nix
  ];
}
