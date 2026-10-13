{ pkgs, username, ... }:

{
  home-manager.users.${username} = { ... }: {
    home.packages = with pkgs; [
      gnumake
      neovim
      ripgrep
    ];

    xdg.configFile = {
      "nvim/init.lua".source = ../../../../home/dotfiles/nvim/init.lua;
      "nvim/after/plugin/telescope.lua".source = ../../../../home/dotfiles/nvim/after/plugin/telescope.lua;
      "nvim/lua/plugins/telescope.lua".source = ../../../../home/dotfiles/nvim/lua/plugins/telescope.lua;
      "nvim/lua/plugins/lsp.lua".source = ../../../../home/dotfiles/nvim/lua/plugins/lsp.lua;
      "nvim/lua/plugins/ui.lua".source = ../../../../home/dotfiles/nvim/lua/plugins/ui.lua;
      "nvim/lua/plugins/treesitter-conform.lua".source = ../../../../home/dotfiles/nvim/lua/plugins/treesitter-conform.lua;
      "nvim/lua/config/sets.lua".source = ../../../../home/dotfiles/nvim/lua/config/sets.lua;
      "nvim/lua/config/remaps.lua".source = ../../../../home/dotfiles/nvim/lua/config/remaps.lua;
      "nvim/lua/config/lazy.lua".source = ../../../../home/dotfiles/nvim/lua/config/lazy.lua;
      "nvim/lua/config/filetypes.lua".source = ../../../../home/dotfiles/nvim/lua/config/filetypes.lua;

      # Go Development
      "nvim/after/ftplugin/go.lua".source = ../../../../home/dotfiles/nvim/after/ftplugin/go.lua;
    };
  };
}
