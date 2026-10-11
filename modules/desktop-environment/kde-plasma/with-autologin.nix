{ username, ... }:

{
  services ={ 
    desktopManager.plasma6.enable = true;
    displayManager = {
      autoLogin = {
        enable = true;
        user = "${username}";
      };
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };

}
