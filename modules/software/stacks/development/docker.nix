{ lib, config, username, ... }:
with lib;
let
  cfg = config.development.docker;
in {
  options.development.docker.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    virtualisation = {
      docker.enable = true;
    };

    home-manager.users.${username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        dockerfile-language-server
        docker-compose-language-service
      ];
    };
  };
}
