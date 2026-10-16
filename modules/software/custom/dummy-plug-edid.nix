{ lib, config, pkgs, ... }:
# Custom EDID for the dummy DisplayPort plug used with Sunshine.
#
# Built from the real Samsung Odyssey G9 (LC49G95T) EDID dump, adding
# client resolutions Sunshine clients request:
#   - 2856x1280 @ 60/120 Hz  (Google Pixel 10 Pro)
#   - 2410x1080 @ 60/120 Hz  (Google Pixel 10 Pro)
#   - 3840x2160 @ 60 Hz      (LG 4K TV / Dell XPS 13 9370, via VIC 97)
# The G9's native 5120x1440 @ 120 Hz (preferred) and all common fallback
# modes (2560x1440/1920x1080 @ 60/120, 2560x1080, 3840x1080 @ 120) are kept.
with lib;
let
  cfg = config.hardware.customEDID;
  edidFile = pkgs.runCommand "dummy-dp-edid" { } ''
    mkdir -p $out/lib/firmware/edid
    cp ${./edid/g9.bin} $out/lib/firmware/edid/g9.bin
  '';
in {
  options.hardware.customEDID = {
    enable = mkEnableOption "custom EDID firmware for the dummy DP plug";
    connector = mkOption {
      type = types.str;
      description = "DRM connector the dummy plug sits in (e.g. DP-1).";
    };
  };

  config = mkIf cfg.enable {
    hardware.firmware = [ edidFile ];
    # On NVIDIA, drm.edid_firmware alone is not enough: the driver only
    # enumerates modes from the EDID when the connector is force-enabled and
    # KMS modeset/fbdev are on (modeset comes from hardware.nvidia.modesetting).
    boot.kernelParams = [
      "nvidia-drm.fbdev=1"
      "video=${cfg.connector}:e"
      "drm.edid_firmware=${cfg.connector}:edid/g9.bin"
    ];
  };
}
