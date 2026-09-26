{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "gaming-pc";

  # Enable networking
  networking.networkmanager.enable = true;

  # Only allow SSH from the Hermes agent's source IP on the 50-network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.10.16 -j ACCEPT
  '';

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
