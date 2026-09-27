{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
    papirus-icon-theme

    # AI
    claude-code

    # Software
    moonlight-qt
    discord

    # Development
    go
    gopls

    # Language servers / dev tools
    gotools
    docker-language-server
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


  # Wallpaper (used by swww + hyprlock)
  xdg.configFile."wallpapers/japan-night.jpg".source = ./wallpapers/japan-night.jpg;

}
