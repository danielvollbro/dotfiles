{ lib, config, inputs, ... }:
with lib;
let
  cfg = config.applications;
in {
  imports = [ inputs.moonshine.nixosModules.default ];

  options.applications.moonshine.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.moonshine.enable {
    services.moonshine = {
      enable = true;
      user = "${config.host.username}";
      uid = 1000;
      openFirewall = true;

      settings = {
        application = [
          {
            title = "Steam";
            command = [
              "/run/current-system/sw/bin/steam"
              "steam://open/bigpicture"
            ];
          }
        ];
      };
    };
  };
}
