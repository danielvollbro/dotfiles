{ lib, config, ... }:
with lib;
let
  cfg = config.network;
in {
  options.network.wakeOnLan = {
    enable = mkEnableOption "wakeOnLan";
    nic = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = {
    networking = mkIf cfg.wakeOnLan.enable {
      interfaces = {
        ${cfg.wakeOnLan.nic} = {
          wakeOnLan.enable = true;
        };
      };
      firewall.allowedUDPPorts = [ 9 ]; 
    };
  };
}
