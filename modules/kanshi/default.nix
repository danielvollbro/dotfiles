{ pkgs, username, ... }:

{
  environment.systemPackages = with pkgs; [ kanshi ];

  home-manager.users.${username} = { ... }: {
    xdg.configFile."kanshi/config".source = ./dotfiles/config;
  };
}
