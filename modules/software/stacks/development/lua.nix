{ lib, config, username, ... }:
with lib;
let
  cfg = config.development.lua;
in {
  options.development.lua.enable = mkOption {
    type = types.bool;
    default = false;
  };
  
  config = mkIf cfg.enable {
    home-manager.users.${username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        stylua
        lua-language-server
      ];
    };
  };
}
