{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" ];
      kernelModules = [ ];
    };

    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/64d0eb6b-ae84-44a9-b099-373f1f9e7cfe";
      fsType = "btrfs";
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/64d0eb6b-ae84-44a9-b099-373f1f9e7cfe";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/64d0eb6b-ae84-44a9-b099-373f1f9e7cfe";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4187-29BF";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    "/mnt/storage" = {
      device = "/dev/disk/by-uuid/46e49c41-17de-418c-b845-3f2cab42b89b";
      fsType = "btrfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/d53ab7b7-fb6b-45c6-9d90-81e1fdb3415d"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
