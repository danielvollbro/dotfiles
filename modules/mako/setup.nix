{ ... }:

{
  home-manager.users.daniel = { ... }: {
    xdg.configFile."mako/config".source = ./dotfiles/config;
  };
}
