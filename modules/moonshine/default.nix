{ inputs, ... }:

{
  imports = [ inputs.moonshine.nixosModules.default ];

  services.moonshine = {
    enable = true;
    user = "daniel";
    uid = 1000;
    openFirewall = true;

    settings = {
      application = [
        {
          title = "Steam";
          command = [
            "/run/current-system/sw/bin/steam"
            "steam://open/bigpicture"
          ];
        }
      ];
    };
  };
}
