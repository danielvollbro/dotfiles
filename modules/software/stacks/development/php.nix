{ lib, config, username, ... }:
with lib;
let
  cfg = config.development;
in {
  options.development.php.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager = mkIf cfg.php.enable {
      users.${username} = { pkgs, ... }: {
        home.packages = [ pkgs.intelephense ];
      };
    };
  };
}
