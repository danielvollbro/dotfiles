{ lib, config, username, ... }:
with lib;
let
  cfg = config.gaming;
in {
  options = {
    gaming = {
      enableLutris = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enableLutris {
    home-manager.users.${username} = { pkgs, ... }: {
      home.packages = [ pkgs.lutris ];
    };
  };
}
