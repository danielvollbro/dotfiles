{ pkgs, username, ... }:

{
  imports = [
    ../../roles/hermes-agent-ssh-access/main.nix
    ../../roles/private-ssh-access/main.nix
    ../../modules/base.nix
    ../../modules/gaming/main.nix
    ../../modules/hardware/gpu/rtx3070.nix
    ../../modules/softwares/applications/sunshine/main.nix
    ../../modules/softwares/desktop-environment/kde-plasma/main.nix
    ../../modules/softwares/network/WOL/main.nix
    ../../modules/softwares/applications/krfb/main.nix
    ./hardware-configuration.nix
  ];

  services.kde = {
    autoLogin = true;
    disable_direct_scan-out = true;
  };

  # Enable gaming software
  gaming = {
    enableSteam = true;
    enableLutris = true;
  };

  networking.hostName = "gaming-pc";

  # Enable networking
  networking.networkmanager.enable = true;

  home-manager.users.${username} = { ... }: {
    home.packages = with pkgs; [ sops ];
  };

  # Sops
  sops = {
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = true;

    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/home/${username}/.ssh/id_ed25519"
    ];

    secrets = {
      SSH_HOST_ED25519_KEY = {
        path = "/etc/ssh/ssh_host_ed25519_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      SSH_HOST_ED25519_PUB_KEY = {
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
        owner = "root";
        group = "root";
        mode = "0644";
      };
    };
  };

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
