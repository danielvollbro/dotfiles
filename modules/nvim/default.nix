{ pkgs, ... }:

{
  home-manager.users.daniel = { ... }: {
    home.packages = with pkgs; [
      neovim
    ];

    xdg.configFile."nvim/init.lua".source = ./dotfiles/init.lua;
    xdg.configFile."nvim/after/plugin/telescope.lua".source = ./dotfiles/after/plugin/telescope.lua;
    xdg.configFile."nvim/lua/plugins/telescope.lua".source = ./dotfiles/lua/plugins/telescope.lua;
    xdg.configFile."nvim/lua/plugins/lsp.lua".source = ./dotfiles/lua/plugins/lsp.lua;
    xdg.configFile."nvim/lua/plugins/ui.lua".source = ./dotfiles/lua/plugins/ui.lua;
    xdg.configFile."nvim/lua/plugins/treesitter-conform.lua".source = ./dotfiles/lua/plugins/treesitter-conform.lua;
    xdg.configFile."nvim/lua/config/sets.lua".source = ./dotfiles/lua/config/sets.lua;
    xdg.configFile."nvim/lua/config/remaps.lua".source = ./dotfiles/lua/config/remaps.lua;
    xdg.configFile."nvim/lua/config/lazy.lua".source = ./dotfiles/lua/config/lazy.lua;
    xdg.configFile."nvim/lua/config/filetypes.lua".source = ./dotfiles/lua/config/filetypes.lua;

    # Go Development
    xdg.configFile."nvim/after/ftplugin/go.lua".source = ./dotfiles/after/ftplugin/go.lua;
  };
}
