{ lib, config, username, ... }:
with lib;
let
  cfg = config.development;
in {
  options.development.terraform.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager = mkIf cfg.terraform.enable {
      users.${username} = { pkgs, ... }: {
        home.packages = [ pkgs.terraform-ls ];
      };
    };
  };
}
