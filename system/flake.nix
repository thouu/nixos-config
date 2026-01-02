# this is stolen from this video at 1:01 https://youtu.be/rEovNpg7J0M?si=7FkCOZOj3apLA0Xd

{
  description = "nixos-tweed system";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, home-manager, ... }@inputs:

  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in 
  {
    nixosConfigurations = {
      thounix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };
        modules = [
          { nixpkgs.overlays = [ (final: prev: { codex = pkgsUnstable.codex; }) ]; }

          ./nonhome/configuration.nix
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          { home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
            home-manager.users.lcd = import ./home/home.nix; }
        ];
      };
    };
  };
}
