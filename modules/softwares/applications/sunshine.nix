{ pkgs, username, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;
    package = pkgs.sunshine.override { cudaSupport = true; };
  };

  hardware.uinput.enable = true;

  users.users.${username} = {
    extraGroups = [ "uinput" ];
  };

  home-manager.users.${username} = { ... }: {
    xdg.configFile = {
      "sunshine/apps.json" = {
        source = ../../../../home/dotfiles/sunshine/apps.json;
      };
      "sunshine/sunshine.conf" = {
        source = ../../../../home/dotfiles/sunshine/sunshine.conf;
      };
    };
  };
}
