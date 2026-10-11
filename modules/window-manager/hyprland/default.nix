{ pkgs, username, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    awww
    hyprlock
    hypridle
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      };
    };
  };

  programs.hyprland.enable = true;

  home-manager.users.${username} = { ... }: {
    xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hyprland.conf;
    xdg.configFile."hypr/hyprlock.conf".source = ./dotfiles/hyprlock.conf;
    xdg.configFile."hypr/hypridle.conf".source = ./dotfiles/hypridle.conf;
  };
}
