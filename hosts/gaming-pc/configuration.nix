{ ... }:

{
  imports = [
    ../base.nix
    ../../roles/hermes-agent-ssh-access/default.nix
    ../../roles/private-ssh-access/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "gaming-pc";

  # Enable networking
  networking.networkmanager.enable = true;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
