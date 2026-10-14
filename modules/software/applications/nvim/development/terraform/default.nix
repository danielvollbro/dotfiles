{ lib, config, ... }:
with lib;
let
  cfg = config.development.terraform;
in {
  options.development.terraform.enable = mkEnableOption "Terraform LSP";

  config = mkIf cfg.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = [ pkgs.terraform-ls ];
    };
  };
}
