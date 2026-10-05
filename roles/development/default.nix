{ pkgs, username, ... }:

{
  imports = [
    ../../modules/applications/nvim/default.nix
  ];

  # Enabled docker
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];
  virtualisation.docker.storageDriver = "btrfs";

  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Development
      go
      gopls
      tmux

      # Language servers / dev tools
      gotools
      dockerfile-language-server-nodejs
      docker-compose-language-service
      terraform-ls
      bash-language-server
      intelephense
      typescript-language-server
      vscode-langservers-extracted  # html, cssls, jsonls
      pyright
      yaml-language-server
      prettier
      stylua
      nixd
      lua-language-server

      # Formatters (conform.nvim) & nvim build deps
      prettierd
      ruff
      shfmt
      nixpkgs-fmt
      gcc  # builds telescope-fzf-native
      tree-sitter  # CLI needed by nvim-treesitter to build parsers
      nodejs  # nvim-treesitter parser build toolchain
    ];
  };
}
