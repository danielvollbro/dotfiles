{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
    papirus-icon-theme

    # AI
    claude-code

    # Software
    moonlight-qt
    discord
  ];


  # Wallpaper (used by swww + hyprlock)
  xdg.configFile."wallpapers/japan-night.jpg".source = ./wallpapers/japan-night.jpg;

}
