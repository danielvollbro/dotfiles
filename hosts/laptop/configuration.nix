{ pkgs, ... }:

{
  imports = [
    ../base.nix
    ../modules/hyprland.nix
    ../modules/dell-xps-13.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "quiet" "udev.log_level=3" ];
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;


  environment.shellAliases = {
    vim = "nvim";
  };

  networking.wireless = {
    secretsFile = "/etc/nixos-secrets/wireless.env";
    networks."Wollbro_Main".pskRaw = "ext:wifi_psk";
  };

  networking.hostName = "daniel-laptop"; # Define your hostname.
  users.users."daniel".openssh.authorizedKeys.keys = [
    # hermes-agent-laptop (J.A.R.V.I.S.)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC5gYdLzF4jUwLYega58MkYMTPVatL0oZGvCWgJB/Ip hermes-agent-laptop"
  ];

  # Only allow SSH from the Hermes agent's source IP on the 50-network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
  '';

  environment.systemPackages = with pkgs; [
    # Development
    docker
  ];

  # Warm dark GTK theme
  programs.dconf.enable = true;
  qt.enable = true;
  qt.platformTheme = "qt5ct";
  qt.style = "kvantum";

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
