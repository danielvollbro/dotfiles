{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.applications;
in {
  options.applications.sunshine.enable = mkEnableOption "Sunshine";

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
        "sunshine/sunshine-switch-mode.sh" = {
          source = ./dotfiles/sunshine-switch-mode.sh;
          executable = true;
        };
        "sunshine/steam-bp-wrapper.sh" = {
          source = ./dotfiles/steam-bp-wrapper.sh;
          executable = true;
        };
      };
    };

    # The Do/Undo commands are referenced in sunshine.conf
    # (do_cmd / undo_cmd) and switch the display to the client's resolution
    # on connect, restoring 1080p on disconnect.
  };
}
