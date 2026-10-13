{ lib, config, username, ... }:
with lib;
let
  cfg = config.network;
in {
  options.network = {
    allowSSHKeysAccess = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    allowIPAccess = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = {
    users.users.${username}.openssh.authorizedKeys = {
      keys = mkDefault cfg.allowSSHKeysAccess;
    };
    networking.firewall.extraCommands = cfg.allowIPAccess;
  };
}
