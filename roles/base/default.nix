{ username, config, lib, ... }:

{
  imports = [
    ../../modules/applications/nvim/default.nix
  ];

  # Shell Aliases
  environment.shellAliases = {
    vim = "nvim";
  };

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

  # Firmware update support
  services.fwupd.enable = true;

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

  # Define a user account. Password comes from sops (USER_PASSWORD_HASH) when
  # that host has the secret defined (currently: laptop). Hosts without it
  # fall back to the old manual `passwd` flow after first login.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "video" ];
    hashedPasswordFile = lib.mkIf
      (config.sops.secrets ? USER_PASSWORD_HASH)
      config.sops.secrets.USER_PASSWORD_HASH.path;
  };

  # SSH access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    # NOTE: do NOT add `hostKeys` paths here. sshd generates default host keys
    # automatically when none are specified. Explicitly pinning a path while the
    # key is no longer delivered by sops (SSH host keys are not secrets anymore)
    # breaks `sshd` on fresh installs: the mapped path never gets a key generated
    # and the unit fails until the file is created manually.
  };

  networking.firewall.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home-manager.users.${username} = { pkgs, ... }: {
    home.username = "${username}";
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "26.05";

    home.packages = with pkgs; [
      firefox-bin
      bitwarden-desktop
    ];

    programs.git = {
      enable = true;
      userName = "Daniel Vollbro";
      userEmail = "daniel@vollbro.com";
    };

    programs.home-manager.enable = true;
  };
}
