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
        # Provided by UWSM (programs.hyprland.withUWSM above) — launches
        # Hyprland under systemd/UWSM session management rather than bare.
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      };
    };
  };

  programs.hyprland.enable = true;
  # UWSM gives Hyprland proper systemd session integration (graphical-session
  # target, env import) and is what provides the `start-hyprland` wrapper
  # binary that tuigreet below launches. Without this, withUWSM defaults to
  # false and that binary is never generated — greetd would fail to exec it.
  programs.hyprland.withUWSM = true;

  home-manager.users.${username} = { ... }: {
    xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hyprland.conf;
    xdg.configFile."hypr/hyprlock.conf".source = ./dotfiles/hyprlock.conf;
    xdg.configFile."hypr/hypridle.conf".source = ./dotfiles/hypridle.conf;
  };
}
