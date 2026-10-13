{ pkgs, lib, config, username, ... }:
with lib;
let
  cfg = config.development;
in {
  imports = [
    ../applications/nvim.nix
    ../applications/tmux.nix
    ./development/docker.nix
    ./development/go.nix
    ./development/lua.nix
    ./development/php.nix
    ./development/terraform.nix
  ];

  options.development.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        # Language servers / dev tools
        bash-language-server
        typescript-language-server
        vscode-langservers-extracted  # html, cssls, jsonls
        pyright
        yaml-language-server
      ];
    };
  };
}
