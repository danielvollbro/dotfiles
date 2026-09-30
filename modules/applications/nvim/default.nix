{ pkgs, username, ... }:

{
  home-manager.users.${username} = { ... }: {
    home.packages = with pkgs; [
      make
      neovim
      ripgrep
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

      # Go Development
      "nvim/after/ftplugin/go.lua".source = ./dotfiles/after/ftplugin/go.lua;
    };
  };
}
