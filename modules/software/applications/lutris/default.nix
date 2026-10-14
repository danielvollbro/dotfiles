{ lib, config, ... }:
with lib;
let
  cfg = config.gaming;
in {
  options.gaming.enableLutris = mkEnableOption "Lutris";

  config = mkIf cfg.enableLutris {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = [ pkgs.lutris ];
    };
  };
}
