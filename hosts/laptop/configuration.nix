{ pkgs, config, ... }:

{
  imports = [
    ../../roles/base/default.nix
    ../../roles/hyprland/default.nix
    ../../roles/dell-xps-13/default.nix
    ../../roles/development/default.nix
    ../../roles/hermes-agent-ssh-access/default.nix
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [ sops ];

  # Sops
  sops = {
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = true;

    age.keyFile = "/mnt/master-age.key";

    secrets.WIFI_PASSWORD_KEY = {
      owner = "wpa_supplicant";
    };

    templates."wireless.env" = {
      content = ''
        WIFI_PASSWORD_KEY=${config.sops.placeholder.WIFI_PASSWORD_KEY}
      '';
      owner = "wpa_supplicant";
    };
  };

  networking.wireless = {
    enable = true;
    secretsFile = config.sops.templates."wireless.env".path;
    networks."Wollbro_Main".pskRaw = "ext:WIFI_PASSWORD_KEY";
  };

  networking.hostName = "daniel-laptop"; # Define your hostname.

  # Warm dark GTK theme
  programs.dconf.enable = true;
  qt.enable = true;
  qt.platformTheme = "qt5ct";
  qt.style = "kvantum";

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
