{ pkgs, lib, config, ... }:
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
    environment = {
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
