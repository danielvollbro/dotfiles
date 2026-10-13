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

  config = mkIf cfg.enableSteam {
    programs = {
      steam = {
        enable = true;
      };
    };
  };
}
