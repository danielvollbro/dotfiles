{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kanshi
  ];

  home-manager.users.daniel = { ... }: {
    xdg.configFile."kanshi/config".source = ./dotfiles/config;
  };
}
