{ ... }:

{
  home-manager.users.daniel = { ... }: {
    xdg.configFile."waybar/config".source = ./dotfiles/config;
    xdg.configFile."waybar/style.css".source = ./dotfiles/style.css;
    xdg.configFile."waybar/sysinfo.sh" = {
      source = ./dotfiles/sysinfo.sh;
      executable = true;
    };
    xdg.configFile."waybar/idle_state.sh" = {
      source = ./dotfiles/idle_state.sh;
      executable = true;
    };
  };
}
