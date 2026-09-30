{
  description = "Daniel Vollbro NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    moonshine.url = "github:hgaiser/moonshine";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    sops-nix,
    ...
  }@inputs:
  let
    username = "daniel";
    # Bootstrap apps: one-command reinstall from a NixOS installer ISO, e.g.
    #   sudo nix --experimental-features "nix-command flakes" run github:danielvollbro/dotfiles#laptop-install
    # (clones the repo, wipes/partitions the disk via disko, places the master
    # age key, runs nixos-install — see installer/bootstrap.sh)
    bootstrapApp = pkgs: host: {
      type = "app";
      program = "${pkgs.writeShellScript "bootstrap-${host}" ''
        export PATH="${pkgs.lib.makeBinPath [
          pkgs.bash pkgs.coreutils pkgs.git pkgs.bitwarden-cli pkgs.jq
        ]}:$PATH"
        exec ${pkgs.bash}/bin/bash ${./installer/bootstrap.sh} ${host} "$@"
      ''}";
    };
  in {
    apps.x86_64-linux.laptop-install = bootstrapApp nixpkgs.legacyPackages.x86_64-linux "laptop";
    apps.x86_64-linux.gaming-pc-install = bootstrapApp nixpkgs.legacyPackages.x86_64-linux "gaming-pc";


    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        nixos-hardware.nixosModules.dell-xps-13-9370
        ./hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home/laptop.nix;
        }
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.gaming-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/gaming-pc/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home/gaming-pc.nix;
        }
        sops-nix.nixosModules.sops
      ];
    };
  };
}
