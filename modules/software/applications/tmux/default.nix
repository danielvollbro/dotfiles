{ lib, config, ... }:
with lib;
let
  cfg = config.applications;
in {
  options.applications.tmux.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.tmux.enable {
    home-manager.users.${config.host.username} = { pkgs, ... }: {
      home.packages = [ pkgs.tmux ];

      xdg.configFile = {
        ".tmux.conf".source = ./dotfiles/.tmux.conf;
      };
    };
  };
}
