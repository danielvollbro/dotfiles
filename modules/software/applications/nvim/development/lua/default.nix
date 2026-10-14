{ lib, config, ... }:
with lib;
let
  cfg = config.development.lua;
in {
  options.development.lua.enable = mkEnableOption "Lua LSP";
  
  config = mkIf cfg.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        stylua
        lua-language-server
      ];
    };
  };
}
