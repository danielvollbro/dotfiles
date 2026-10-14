{ lib, config, ... }:
with lib;
let
  cfg = config.development;
in {
  imports = [
    ./docker/default.nix
    ./go/default.nix
    ./lua/default.nix
    ./php/default.nix
    ./terraform/default.nix
  ];

  options.development.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    # Make sure nvim and tmux is enabled
    applications = {
      nvim.enable = true;
      tmux.enable = true;
    };

    home-manager.users.${config.host.username} = { pkgs, ... }: {
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
