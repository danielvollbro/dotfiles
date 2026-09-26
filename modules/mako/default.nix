{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ mako ];

  home-manager.users.daniel = { ... }: {
    xdg.configFile."mako/config".source = ./dotfiles/config;
  };
}
