{ lib, config, username, ... }:
with lib;
let
  cfg = config.development;
in {
  options.development.docker.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    virtualisation = mkIf cfg.docker.enable {
      docker.enable = true;
    };

    home-manager = mkIf cfg.docker.enable {
      users.${username} = { pkgs, ... }: {
        home.packages = with pkgs; [
          dockerfile-language-server
          docker-compose-language-service
        ];
      };
    };
  };
}
