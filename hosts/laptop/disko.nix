{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            luksSwap = {
              priority = 2;
              name = "luksSwap";
              size = "17G";
              content = {
                type = "luks";
                name = "cryptswap";
                settings.allowDiscards = true;
                # Read non-interactively from a file the installer writes
                # after a retry-looped (matching) prompt — see
                # installer/bootstrap.sh. Without this, disko asks for the
                # passphrase TWICE per container (4x total for root+swap)
                # with zero tolerance for a typo: one mismatch aborts the
                # whole install with everything already wiped.
                passwordFile = "/tmp/disko-luks.key";
                content = {
                  type = "swap";
                  discardPolicy = "both";
                  resumeDevice = true;
                };
              };
            };

            luksRoot = {
              priority = 3;
              name = "luksRoot";
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                passwordFile = "/tmp/disko-luks.key";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
