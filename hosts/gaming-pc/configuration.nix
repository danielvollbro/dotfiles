{ pkgs, username, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/hardware/gpu/rtx3070.nix
    ../../modules/softwares/applications/krfb.nix
    ../../modules/softwares/applications/sunshine.nix
    ../../modules/softwares/desktop-environment/kde-plasma.nix
    ../../modules/softwares/stacks/gaming.nix
    ./hardware-configuration.nix
  ];

  services.kde = {
    autoLogin = true;
    disableDirectScanOut = true;
  };

  # Enable gaming software
  gaming = {
    enableSteam = true;
    enableLutris = true;
  };

  network = {
    wakeOnLan = {
      enable = true;
      nic = "enp5s0";
    };
    allowSSHKeysAccess = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC5gYdLzF4jUwLYega58MkYMTPVatL0oZGvCWgJB/Ip hermes-agent",
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjzcieQ64SuEq6swAfKlt540QKNJs6wNIcmOEEs0Uya daniel@nixos"
    ];
    allowIPAccess = ''
      iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
      iptables -A nixos-fw -p tcp --dport 22 -s 10.0.10.16 -j ACCEPT
    '';
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
