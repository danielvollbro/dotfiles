{ lib, config, ... }:
with lib;
let
  cfg = config.development.docker;
in {
  options.development.docker.enable = mkEnableOption "Docker LSP";

  config = mkIf cfg.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        dockerfile-language-server
        docker-compose-language-service
      ];
    };
  };
}
