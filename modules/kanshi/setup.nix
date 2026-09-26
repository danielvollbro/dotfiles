{ ... }:

{
  home-manager.users.daniel = { ... }: {
    xdg.configFile."kanshi/config".source = ./dotfiles/config;
  };
}
