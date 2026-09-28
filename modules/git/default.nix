{ username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = with pkgs; [
      git
    ];
  };
}
