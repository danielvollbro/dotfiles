{ nic, ... }:

{
  networking = {
    interfaces = {
      ${nic} = {
        wakeOnLan.enable = true;
      };
    };
    firewall.allowedUDPPorts = [ 9 ]; 
  };
}
