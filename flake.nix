# thank you vimjoyer https://youtu.be/rEovNpg7J0M

{ description = "nixos multi-host system (tweed + mylar)";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, home-manager, ... }@inputs:

  let
    unstableOverlay = final: prev:
      let
        pkgsUnstable = import nixpkgs-unstable {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
        unstablePackages = [
          "codex"
          "claude-code"
          "opencode"
        ];
        # i have to add netbird here because ssh isn't enabled otherwise
        # netbird on nixpkgs-unstable is >1yr old somehow
        netbirdOverride = pkgsUnstable.netbird.overrideAttrs (old: {
          version = "0.73.2";
          src = prev.fetchFromGitHub {
            owner = "netbirdio";
            repo = "netbird";
            rev = "v0.73.2";
            hash = "sha256-cb8yUQWK6sjf947RuQTIhoHNxO9BrPbpwCQCjCyNGwg=";
          };
          vendorHash = "sha256-qa++ONGrFsKJTK7R6Q/9FsMfptKNK9bza32nFKosDxY=";
        });
      in
      (builtins.listToAttrs (map (name: {
        inherit name;
        value = pkgsUnstable.${name};
      }) unstablePackages)) // {
        netbird = netbirdOverride;
      };

    mkHost = hostname: system: nixpkgs.lib.nixosSystem {
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
      tweed = mkHost "tweed" "x86_64-linux";
      mylar = mkHost "mylar" "aarch64-linux";
    };
  };
}
