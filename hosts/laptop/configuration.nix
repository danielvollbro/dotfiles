{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "quiet" "udev.log_level=3" ];
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.blueman.enable = true;

  systemd.services.dhcpcd.serviceConfig = {
    StandardOutput = "journal";
    StandardError = "journal";
  };

  networking.hostName = "daniel-laptop"; # Define your hostname.
  networking.wireless = {
    enable = true;  # Enables wireless support via wpa_supplicant.
    userControlled = true;
    secretsFile = "/etc/nixos-secrets/wireless.env";
    networks."Wollbro_Main".pskRaw = "ext:wifi_psk";
  };

  # Battery management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_BAT = "auto";
      WIFI_PWR_ON_BAT = "on";
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
  services.power-profiles-daemon.enable = false;

  # Touchpad
  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
  };

  # Aggressive runtime power management (USB autosuspend, PCIe, audio codecs)
  powerManagement.powertop.enable = true;

  # What happens when you close the lid
  services.logind.settings.Login.HandleLidSwitch = "hibernate";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # SSD improvements
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    # System
    brightnessctl
    wireplumber
    playerctl
    mako
    libva-utils
    yazi
    kanshi
    grim

    # Hyprland requirements
    kitty
    waybar
    rofi
    awww
    hyprlock
    hypridle

    # AI
    claude-code
  
    # Software
    neovim
    firefox-bin
    moonlight-qt
    discord
    bitwarden-desktop

    # Development
    go
    gopls
    docker
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  # Warm dark GTK theme
  programs.dconf.enable = true;
  qt.enable = true;
  qt.platformTheme = "qt5ct";
  qt.style = "kvantum";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      };
    };
  };

  programs.hyprland.enable = true;

  # Only allow SSH from the Hermes agent's source IP on the 50-network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
  '';

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
