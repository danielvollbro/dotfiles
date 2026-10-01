{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ ];
      luks.devices = {
        "cryptroot" = {
          # /dev/disk/by-partlabel/disk-main-luksRoot — set by disko, stable
          # across reinstalls (unlike UUIDs, which change on every reformat).
          device = "/dev/disk/by-partlabel/disk-main-luksRoot";
        };
        "cryptswap" = {
          device = "/dev/disk/by-partlabel/disk-main-luksSwap";
          allowDiscards = true;
          # Unlocked with a keyfile on the (TPM-unlocked) root filesystem,
          # so swap opens automatically after cryptroot — no passphrase,
          # no separate TPM enrollment. Kept 0600 root-owned.
          keyFile = "/var/lib/luks-swap.key";
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

    "/boot" = {
      # /dev/disk/by-partlabel/disk-main-ESP — set by disko, stable across
      # reinstalls (unlike the vfat UUID, which changes on every reformat).
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    "/home" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

    "/nix" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
  };

  swapDevices = [
    { device = "/dev/mapper/cryptswap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
