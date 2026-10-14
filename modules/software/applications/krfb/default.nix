{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.applications;
in {
  options.applications.krfb.enable = mkOption {
    type = types.bool;
    default = false;
  };
  config = mkIf cfg.krfb.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.krfb
      kdePackages.kscreen
    ];
  };
}
