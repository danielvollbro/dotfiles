{ username, ... }:

{
  imports = [
    ../../modules/kde-plasma/default.nix
    ../../modules/krfb/default.nix
    ../../modules/sunshine/default.nix
    ../../modules/wol/default.nix
  ];

  environment.sessionVariables = {
    KWIN_DRM_NO_DIRECT_SCANOUT = "1";
  };

  home-manager.users.${username}.xdg.configFile."powerdevilrc".text = ''
    [AC][DPMSControl]
    idleTime=0
    [AC][DimDisplay]
    dimWhenIdle=false
    [AC][SuspendSession]
    idleTime=3600
  '';

  services.logind.settings.Login.IdleAction = "ignore";
}
