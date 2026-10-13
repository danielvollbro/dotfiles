{ pkgs, lib, ... }:
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
      enableLutris = mkOption {
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

    environment = mkIf cfg.enableLutris {
      systemPackages = with pkgs; [
        lutris

        (lutris.override {
          # List of additional system libraries
          extraLibraries = pkgs: [ ];

          # List of additional system packages    
          extraPkgs = pkgs: [ ];
        })
      ];
    };
  };
}
