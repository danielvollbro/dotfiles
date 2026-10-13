{ username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
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
      "nvim/init.lua".source = ../../../home/dotfiles/nvim/init.lua;
      "nvim/after/plugin/telescope.lua".source = ../../../home/dotfiles/nvim/after/plugin/telescope.lua;
      "nvim/lua/plugins/telescope.lua".source = ../../../home/dotfiles/nvim/lua/plugins/telescope.lua;
      "nvim/lua/plugins/lsp.lua".source = ../../../home/dotfiles/nvim/lua/plugins/lsp.lua;
      "nvim/lua/plugins/ui.lua".source = ../../../home/dotfiles/nvim/lua/plugins/ui.lua;
      "nvim/lua/plugins/treesitter-conform.lua".source = ../../../home/dotfiles/nvim/lua/plugins/treesitter-conform.lua;
      "nvim/lua/config/sets.lua".source = ../../../home/dotfiles/nvim/lua/config/sets.lua;
      "nvim/lua/config/remaps.lua".source = ../../../home/dotfiles/nvim/lua/config/remaps.lua;
      "nvim/lua/config/lazy.lua".source = ../../../home/dotfiles/nvim/lua/config/lazy.lua;
      "nvim/lua/config/filetypes.lua".source = ../../../home/dotfiles/nvim/lua/config/filetypes.lua;
    };
  };
}
