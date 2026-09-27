{ ... }:

{
  imports = [
    ../../roles/base/default.nix
    ../../roles/hermes-agent-ssh-access/default.nix
    ../../roles/private-ssh-access/default.nix
    ../../roles/remote-machine/kde.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "gaming-pc";

  # Enable networking
  networking = {
    useDHCP = false;
    interfaces.enp5s0 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = "10.0.10.140";
        prefixLength = 24;
      } ];
    };
    defaultGateway = "10.0.10.1";
    nameservers = [ "10.0.55.20" "10.0.50.10" ];
    networkmanager.enable = true;
  };

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
