{ ... }:

{
  imports = [
    ../../modules/kde-plasma/default.nix
    ../../modules/krfb/default.nix
    ../../modules/sunshine/default.nix
    ../../modules/hardware/gpu/rtx3070/default.nix
    ../../modules/wol/default.nix
  ];

  environment.sessionVariables = {
    KWIN_DRM_NO_DIRECT_SCANOUT = "1";
  };

  environment.etc."xdg/powerdevilrc".text = ''
    [Battery][General]
    [AC][DPMSControl]
    idleTime=0
    [AC][DimDisplay]
    dimWhenIdle=false
  '';

  services.logind.settings.Login.IdleAction = "ignore";
}
