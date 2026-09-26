# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "headless-pc"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Only allow SSH from the Hermes agent's source IP on6the 50-network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.10.16 -j ACCEPT
  '';

  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
