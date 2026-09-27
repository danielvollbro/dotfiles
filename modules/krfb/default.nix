{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.krfb
    kdePackages.kscreen
  ];
}
