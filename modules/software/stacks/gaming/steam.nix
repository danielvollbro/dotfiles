{ lib, config, ... }:
with lib;
let
  cfg = config.gaming;
in {
  options = {
    gaming = {
      enableSteam = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = {
    programs = mkIf cfg.enableSteam {
      steam = {
        enable = true;
      };
    };
  };
}
