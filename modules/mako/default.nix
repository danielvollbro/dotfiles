{ pkgs, username, ... }:

{
  environment.systemPackages = with pkgs; [ mako ];

  home-manager.users.${username} = { ... }: {
    xdg.configFile."mako/config".source = ./dotfiles/config;
  };
}
