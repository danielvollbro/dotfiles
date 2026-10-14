{ lib, config, ... }:
with lib;
let
  cfg = config.development.php;
in {
  options.development.php.enable = mkEnableOption "PHP LSP";

  config = mkIf cfg.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = [ pkgs.intelephense ];
    };
  };
}
