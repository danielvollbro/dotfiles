{ pkgs, ... }:

{
  imports = [
    ../../modules/hyprland/setup.nix
    ../../modules/rofi/setup.nix
    ../../modules/mako/setup.nix
    ../../modules/kanshi/setup.nix
    ../../modules/waybar/setup.nix
  ];
}
