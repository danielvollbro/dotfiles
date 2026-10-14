{ lib, config, ... }:
with lib;
let
  cfg = config.applications;
in {
  imports = [
    ./development/default.nix
  ];
  
  options.applications.nvim.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.nvim.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = with pkgs; [
        # Main bin
        neovim

        # Language servers / dev tools
        nixd
        prettier

        # Formatters (conform.nvim) & nvim build deps
        gcc  # builds telescope-fzf-native
        gnumake
        nixpkgs-fmt
        nodejs  # nvim-treesitter parser build toolchain
        prettierd
        ripgrep
        ruff
        shfmt
        tree-sitter  # CLI needed by nvim-treesitter to build parsers
      ];

      xdg.configFile = {
        "nvim/init.lua".source = ./dotfiles/init.lua;
        "nvim/after/plugin/telescope.lua".source = ./dotfiles/after/plugin/telescope.lua;
        "nvim/lua/plugins/telescope.lua".source = ./dotfiles/lua/plugins/telescope.lua;
        "nvim/lua/plugins/lsp.lua".source = ./dotfiles/lua/plugins/lsp.lua;
        "nvim/lua/plugins/ui.lua".source = ./dotfiles/lua/plugins/ui.lua;
        "nvim/lua/plugins/treesitter-conform.lua".source = ./dotfiles/lua/plugins/treesitter-conform.lua;
        "nvim/lua/config/sets.lua".source = ./dotfiles/lua/config/sets.lua;
        "nvim/lua/config/remaps.lua".source = ./dotfiles/lua/config/remaps.lua;
        "nvim/lua/config/lazy.lua".source = ./dotfiles/lua/config/lazy.lua;
        "nvim/lua/config/filetypes.lua".source = ./dotfiles/lua/config/filetypes.lua;
      };
    };
  };
}
