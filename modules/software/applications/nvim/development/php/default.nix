{ lib, config, ... }:
with lib;
let
  cfg = config.development.php;
in {
  options.development.php.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = [ pkgs.intelephense ];
    };
  };
}
