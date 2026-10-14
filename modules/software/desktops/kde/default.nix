{ lib, config, ... }:
with lib;
let
  cfg = config.desktops.kde;
in {
  options.desktops.kde = {
    enable = mkEnableOption "kde plasma 6";
    autoLogin = mkEnableOption "auto login";
    disableDirectScanOut = mkEnableOption "disable direct scan out";
    preventIdle = mkEnableOption "prevent computer to idle";
  };

  config = mkIf cfg.enable {
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
          user = "${config.host.username}";
        };
      };
    };

    environment.sessionVariables = mkIf cfg.disableDirectScanOut {
      KWIN_DRM_NO_DIRECT_SCANOUT = "1";
    };

    home-manager.users.${config.host.username}.xdg.configFile = mkIf cfg.preventIdle {
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
