{ ... }:

{
  # Enable WOL (Wake On Lan)
  networking = {
    interfaces = {
      enp5s0 = {
        wakeOnLan.enable = true;
      };
    };
    firewall.allowedUDPPorts = [ 9 ]; 
  };
}
