{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.applications;
in {
  options.applications.sunshine.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      capSysAdmin = true;
      package = pkgs.sunshine.override { cudaSupport = true; };
    };

    hardware.uinput.enable = true;

    users.users.${config.host.username} = {
      extraGroups = [ "uinput" ];
    };

    home-manager.users.${config.host.username} = { ... }: {
      xdg.configFile = {
        "sunshine/apps.json" = {
          source = ./dotfiles/apps.json;
        };
        "sunshine/sunshine.conf" = {
          source = ./dotfiles/sunshine.conf;
        };
      };
    };
  };
}
