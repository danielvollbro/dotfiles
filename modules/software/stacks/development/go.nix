{ lib, config, username, ... }:
with lib;
let
  cfg = config.development.go;
in {
  options.development.go.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        go
        gopls
        gotools
      ];

      xdg.configFile = {
        "nvim/after/ftplugin/go.lua".source = ../../../../home/dotfiles/nvim/after/ftplugin/go.lua;
      };
    };
  };
}
