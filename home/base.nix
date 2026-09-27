{ pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    firefox-bin
    bitwarden-desktop
  ];

  programs.home-manager.enable = true;
}
