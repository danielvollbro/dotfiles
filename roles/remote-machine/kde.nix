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
}
