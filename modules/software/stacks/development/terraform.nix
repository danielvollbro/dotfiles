{ lib, config, username, ... }:
with lib;
let
  cfg = config.development.terraform;
in {
  options.development.terraform.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = { pkgs, ... }: {
      home.packages = [ pkgs.terraform-ls ];
    };
  };
}
