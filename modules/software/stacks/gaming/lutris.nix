{ lib, config, ... }:
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
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = [ pkgs.lutris ];
    };
  };
}
