{ pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # System
    git

    # Software
    neovim
    firefox-bin
    bitwarden-desktop
  ];

  programs.home-manager.enable = true;

  # Symlink the dotfiles in this repo into place instead of managing them by hand
  xdg.configFile."nvim/init.lua".source = ../home/nvim/init.lua;
  xdg.configFile."nvim/after/plugins/telescope.lua".source = ../home/nvim/after/plugins/telescope.lua;
  xdg.configFile."nvim/lua/plugins/telescope.lua".source = ../home/nvim/lua/plugins/telescope.lua;
  xdg.configFile."nvim/lua/plugins/lsp.lua".source = ../home/nvim/lua/plugins/lsp.lua;
  xdg.configFile."nvim/lua/plugins/ui.lua".source = ../home/nvim/lua/plugins/ui.lua;
  xdg.configFile."nvim/lua/plugins/treesitter-conform.lua".source = ../home/nvim/lua/plugins/treesitter-conform.lua;
  xdg.configFile."nvim/lua/config/sets.lua".source = ../home/nvim/lua/config/sets.lua;
  xdg.configFile."nvim/lua/config/remaps.lua".source = ../home/nvim/lua/config/remaps.lua;
  xdg.configFile."nvim/lua/config/lazy.lua".source = ../home/nvim/lua/config/lazy.lua;

  # Go Development
  xdg.configFile."nvim/after/ftplugin/go.lua".source = ../home/nvim/after/ftplugin/go.lua;
}
