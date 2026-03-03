# this is partly stolen from this video at 1:01 https://youtu.be/rEovNpg7J0M?si=7FkCOZOj3apLA0Xd

{ description = "nixos multi-host system (tweed + mylar)";
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

    unstableOverlay = final: prev:
      let
        unstablePackages = [
          "codex"
          "claude-code"
          "opencode"
        ];
        # i have to add netbird here because ssh isn't enabled otherwise
        # netbird on nixpkgs-unstable is >1yr old somehow
        netbirdOverride = pkgsUnstable.netbird.overrideAttrs (old: {
          version = "0.66.1";
          src = prev.fetchFromGitHub {
            owner = "netbirdio";
            repo = "netbird";
            rev = "v0.66.1";
            hash = "sha256-n9sfEyS2wHcf2K2GO49l9r9lDs1rv6oC2PCnl4wy75M=";
          };
          vendorHash = "sha256-zMjbciItpzzCmUoLZy+gEF9etQy2dRmZrRVg4iSC0+o=";
        });
      in
      (builtins.listToAttrs (map (name: {
        inherit name;
        value = pkgsUnstable.${name};
      }) unstablePackages)) // {
        netbird = netbirdOverride;
      };

    mkHost = hostname: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs system; };
      modules = [
        {
          nixpkgs.overlays = [ unstableOverlay ];
        }
        ./hosts/${hostname}/configuration.nix
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        }
      ];
    };
  in
  {
    nixosConfigurations = {
      tweed = mkHost "tweed";
      mylar = mkHost "mylar";
    };
  };
}
