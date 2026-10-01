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
        # `programs.hyprland.enable` only puts a `Hyprland` binary (capital H)
        # on PATH — there is no `start-hyprland` wrapper anywhere in this
        # repo. Pointing tuigreet at the nonexistent name would make the
        # greeter fail to exec anything after a fresh install (caught during
        # reinstall pre-flight review, never actually hit in production
        # since the running laptop wasn't reinstalled since this was added).
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
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
