{ config, ... }:

{
  imports = [
    ../../base.nix
    ../../hardware/gpu/rtx3070.nix
    ./hardware-configuration.nix
  ];

  desktops.kde = {
    enable = true;
    autoLogin = true;
    disableDirectScanOut = true;
  };

  # Dummy DP plug for Sunshine: force a custom EDID with the resolutions
  # requested by streaming clients (Pixel 10 Pro, LG 4K TV, XPS 13).
  hardware.customEDID = {
    enable = true;
    connector = "DP-1";
  };

  applications = {
    krfb.enable = true;
    sunshine.enable = true;
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
      config.vars.sshKeys.hermes-agent
      config.vars.sshKeys.daniel-laptop
    ];
    allowIPAccess = ''
      iptables -A nixos-fw -p tcp --dport 22 -s ${config.vars.hosts.docker-debian.ip} -j ACCEPT
      iptables -A nixos-fw -p tcp --dport 22 -s ${config.vars.hosts.laptop.ip} -j ACCEPT
      iptables -A nixos-fw -p tcp --dport 47990 -s ${config.vars.hosts.docker-debian.ip} -j ACCEPT
    '';
  };

  networking.hostName = "gaming-pc";

  # Enable networking
  networking.networkmanager.enable = true;

  home-manager.users.${config.host.username} = { pkgs, ... }: {
    home.packages = with pkgs; [ sops ];
  };

  # Sops
  sops = {
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = true;

    age.keyFile = "/var/lib/sops/age/master.key";

    secrets = {
      USER_PASSWORD_HASH = {
        neededForUsers = true;
      };
    };
  };

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
