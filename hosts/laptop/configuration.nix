{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [ "quiet" "udev.log_level=3" ];
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

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

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  # Battery management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
  services.power-profiles-daemon.enable = false;

  # What happens when you close the lid
  services.logind.settings.Login.HandleLidSwitch = "hibernate";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # SSD improvements
  services.fstrim.enable = true;

  # Firmware update support
  services.fwupd.enable = true;

  # Intel Thermald
  services.thermald.enable = true;

  # Swap in RAM
  zramSwap.enable = true;

  # Auto garbage collect
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."daniel" = {
    isNormalUser = true;
    description = "Daniel Vollbro";
    extraGroups = [ "wheel" "input" "video" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      # hermes-agent-laptop (J.A.R.V.I.S.)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC5gYdLzF4jUwLYega58MkYMTPVatL0oZGvCWgJB/Ip hermes-agent-laptop"
    ];
  };

  # SSH access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Only allow SSH from the Hermes agent's source IP on the 50-network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # System
    brightnessctl
    wireplumber
    playerctl
    mako
    libva-utils
    yazi
    wget
    xclip
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
    vim
    neovim
    firefox-bin
    moonlight-qt
    discord
    bitwarden-desktop

    # Development
    git
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

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  # Audio
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
  security.rtkit.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      };
    };
  };

  programs.hyprland.enable = true;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";

}
