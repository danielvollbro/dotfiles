{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rofi
  ];

  home-manager.users.daniel = { ... }: {
    xdg.configFile."rofi/config.rasi".source = ./dotfiles/config.rasi;
    xdg.configFile."rofi/rofi.warm.rasi".source = ./dotfiles/rofi.warm.rasi;
  };
}
