{ username, ... }:

{
  imports = [
    ../../modules/applications/kde-plasma/default.nix
    ../../modules/applications/krfb/default.nix
    ../../modules/applications/sunshine/default.nix
    ../../roles/enable/wol/default.nix
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
