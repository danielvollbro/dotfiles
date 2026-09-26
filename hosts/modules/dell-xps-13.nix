{ pkgs, ... }:

{
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
  networking.wireless = {
    enable = true;  # Enables wireless support via wpa_supplicant.
    userControlled = true;
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
    wget
    xclip
    kanshi
    grim
  ];

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

}
