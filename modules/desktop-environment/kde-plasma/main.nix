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
    disable_direct_scan-out = mkOption {
      type = types.bool;
      default = false;
    };
    prevent_idle = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    services = {
      logind.settings.Login = mkIf cfg.prevent_idle {
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

    environment.sessionVariables = mkIf cfg.disable_direct_scan-out {
      KWIN_DRM_NO_DIRECT_SCANOUT = "1";
    };

    home-manager.users.${username}.xdg.configFile = mkIf cfg.prevent_idle {
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
