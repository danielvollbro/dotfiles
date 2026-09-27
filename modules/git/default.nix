{ ... }:

{
  home-manager.users.daniel = { pkgs, ... }: {
    home.packages = with pkgs; [
      git
    ];
  };
}
