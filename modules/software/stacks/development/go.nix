{ lib, config, ... }:
with lib;
let
  cfg = config.development.go;
in {
  options.development.go.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
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
