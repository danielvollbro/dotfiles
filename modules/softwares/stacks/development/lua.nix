{ lib, config, username, ... }:
with lib;
let
  cfg = config.development;
in {
  options.development.lua.enable = mkOption {
    type = types.bool;
    default = false;
  };
  
  config = mkIf cfg.enable {
    home-manager = mkIf cfg.lua.enable {
      users.${username} = { pkgs, ... }: {
        home.packages = with pkgs; [
          stylua
          lua-language-server
        ];
      };
    };
  };
}
