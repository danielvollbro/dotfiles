{ lib, config, ... }:
with lib;
let
  cfg = config.development.go;
in {
  options.development.go.enable = mkEnableOption "Go LSP";

  config = mkIf cfg.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        go
        gopls
        gotools
      ];

      xdg.configFile = {
        "nvim/after/ftplugin/go.lua".source = ./dotfiles/after/ftplugin/go.lua;
      };
    };
  };
}
