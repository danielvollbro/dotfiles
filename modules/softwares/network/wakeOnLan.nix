{ lib, config, ... }:
with lib;
let
  cfg = config.network;
in {
  options.network.wakeOnLan = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    nic = mkOption {
      type = types.string;
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
