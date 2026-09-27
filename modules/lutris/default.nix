{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lutris

    (lutris.override {
      # List of additional system libraries
      extraLibraries = pkgs: [ ];

      # List of additional system packages    
      extraPkgs = pkgs: [ ];
    })
  ];
}
