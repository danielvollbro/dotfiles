{ lib, config, ... }:
with lib;
let
  cfg = config.gaming;
in {
  options.gaming.enableSteam = mkEnableOption "Steam";

  config = mkIf cfg.enableSteam {
    programs.steam.enable = true;
  };
}
