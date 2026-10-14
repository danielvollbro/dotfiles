{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.desktops;
in {
  options.desktops.hyprland.enable = mkEnableOption "Hyprland";

  config = mkIf cfg.hyprland.enable {
    environment.systemPackages = with pkgs; [
      kitty
      awww
      hyprlock
      hypridle
      rofi
      mako
      kanshi
      waybar
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

    home-manager.users.${config.host.username} = { ... }: {
      # Waybar
      xdg.configFile."waybar/config".source = ./dotfiles/waybar/config;
      xdg.configFile."waybar/style.css".source = ./dotfiles/waybar/style.css;
      xdg.configFile."waybar/sysinfo.sh" = {
        source = ./dotfiles/waybar/sysinfo.sh;
        executable = true;
      };
      xdg.configFile."waybar/idle_state.sh" = {
        source = ./dotfiles/waybar/idle_state.sh;
        executable = true;
      };

      # Kanshi
      xdg.configFile."kanshi/config".source = ./dotfiles/kanshi/config;

      # Mako
      xdg.configFile."mako/config".source = ./dotfiles/mako/config;

      # Rofi
      xdg.configFile."rofi/config.rasi".source = ./dotfiles/rofi/config.rasi;
      xdg.configFile."rofi/rofi.warm.rasi".source = ./dotfiles/rofi/rofi.warm.rasi;

      # Hyprland
      xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hyprland/hyprland.conf;
      xdg.configFile."hypr/hyprlock.conf".source = ./dotfiles/hyprland/hyprlock.conf;
      xdg.configFile."hypr/hypridle.conf".source = ./dotfiles/hyprland/hypridle.conf;

      # Wallpaper (used by swww + hyprlock)
      xdg.configFile."wallpapers/japan-night.jpg".source = ./wallpapers/japan-night.jpg;
    };
  };
}
