{ ... }:

{
  services ={ 
    desktopManager.plasma6.enable = true;
    displayManager = {
      autoLogin = {
        enable = true;
        user = "daniel";
      };
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };

}
