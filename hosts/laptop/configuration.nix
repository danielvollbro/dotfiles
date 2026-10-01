{ pkgs, lib, config, username, ... }:

{
  imports = [
    ../../roles/base/default.nix
    ../../roles/hyprland/default.nix
    ../../roles/development/default.nix
    ../../roles/hermes-agent-ssh-access/default.nix
    ../../modules/custom/laptop-screen-watchdog/default.nix
    ./hardware-configuration.nix
  ];

  home-manager.users.${username} = { ... }: {
    home.packages = with pkgs; [
      sops
      unzip

      sbctl
    ];
  };

  # Aggressive runtime power management (USB autosuspend, PCIe, audio codecs)
  powerManagement.powertop.enable = true;

  # Audio
  security.rtkit.enable = true;

  # Warm dark GTK theme
  programs.dconf.enable = true;
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  systemd.services.dhcpcd.serviceConfig = {
    StandardOutput = "journal";
    StandardError = "journal";
  };

  # lanzaboote
  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # TPM
  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [
    "tpm_crb" "tpm_tis"
  ];

  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [
    "tpm2-device=auto"
    "tpm2-pcrs=0+2+7+12"
  ];

  # Sops
  sops = {
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = true;

    age.keyFile = "/var/lib/sops/age/master.key";

    secrets = {
      WIFI_PASSWORD_KEY = {
        owner = "wpa_supplicant";
      };
      # neededForUsers: sops normally decrypts secrets AFTER NixOS creates
      # users, but hashedPasswordFile needs the secret to exist BEFORE user
      # creation. This makes sops decrypt it early, to /run/secrets-for-users.
      USER_PASSWORD_HASH = {
        neededForUsers = true;
      };
      SSH_USER_ED25519_KEY = {
        path = "/home/${username}/.ssh/id_ed25519";
        owner = "${username}";
        group = "users";
        mode = "0600";
      };
      SSH_USER_ED25519_PUB_KEY = {
        path = "/home/${username}/.ssh/id_ed25519.pub";
        owner = "${username}";
        group = "users";
        mode = "0644";
      };
    };

    templates = {
      "wireless.env" = {
        content = ''
          WIFI_PASSWORD_KEY=${config.sops.placeholder.WIFI_PASSWORD_KEY}
        '';
        owner = "wpa_supplicant";
      };
    };
  };

  environment = { 
    systemPackages = with pkgs; [
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
    ];

    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };
  };

  networking = {
    wireless = {
      enable = true;
      userControlled = true;
      secretsFile = config.sops.templates."wireless.env".path;
      networks."Wollbro_Main".pskRaw = "ext:WIFI_PASSWORD_KEY";
    };

    hostName = "daniel-laptop";
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
      ];
    };
  };

  services = {
    blueman.enable = true;

    # Battery management
    tlp = {
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
    power-profiles-daemon.enable = false;

    # What happens when you close the lid
    logind.settings.Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "ignore";
    };

    # SSD improvements
    fstrim.enable = true;

    # Sound
    pipewire = {
      enable = true;
      pulse.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    # Touchpad
    libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
    };
  };

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "26.05";
}
