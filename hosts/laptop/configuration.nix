{ ... }:

{
  imports = [
    ../base.nix
    ../../roles/hyprland/default.nix
    ../../roles/dell-xps-13/default.nix
    ../../roles/development/default.nix
    ../../roles/hermes-agent-access/default.nix
    ./hardware-configuration.nix
  ];

  environment.shellAliases = {
    vim = "nvim";
  };

  networking.wireless = {
    secretsFile = "/etc/nixos-secrets/wireless.env";
    networks."Wollbro_Main".pskRaw = "ext:wifi_psk";
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
