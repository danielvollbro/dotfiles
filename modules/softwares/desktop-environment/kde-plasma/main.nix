{ lib, config, username, ... }:
with lib;
let
  cfg = config.services.kde;
in {
  options.services.kde = {
    autoLogin = mkOption {
      type = types.bool;
      default = false;
    };
    disableDirectScanOut = mkOption {
      type = types.bool;
      default = false;
    };
    preventIdle = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    services = {
      logind.settings.Login = mkIf cfg.preventIdle {
        IdleAction = "ignore";
      };

      desktopManager.plasma6.enable = true;

      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };

        # Enable auto login
        autoLogin = mkIf cfg.autoLogin {
          enable = true;
          user = "${username}";
        };
      };
    };

    environment.sessionVariables = mkIf cfg.disableDirectScanOut {
      KWIN_DRM_NO_DIRECT_SCANOUT = "1";
    };

    home-manager.users.${username}.xdg.configFile = mkIf cfg.preventIdle {
      "powerdevilrc".text = ''
        [AC][DPMSControl]
        idleTime=0
        [AC][DimDisplay]
        dimWhenIdle=false
        [AC][SuspendSession]
        idleTime=3600
      '';
    };
  };
}
