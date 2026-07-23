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
    unstableOverlay = final: prev: # creating a function called unstableOverlay that takes `final` & `prev` (which, btw, if the only other place unstableOverlay is called is after nixpkgs.overlays, what is being passed as final & prev?)
      let # defining variable section
        pkgsUnstable = import nixpkgs-unstable { # creating an attribute set called pkgsUnstable that imports nixpkgs-unstable
          system = final.stdenv.hostPlatform.system; # making system equal final.stdenv.hostPlatform.system inside of the new attribute set
          config.allowUnfree = true; # allowing unfree packages inside of the new attribute set
        }; # now there's a thing called pkgsUnstable which is a modified version of nixpkgs-unstable with system = final.stdenv.hostPlatform.system and config.allowUnfree = true
        unstablePackages = [ # just creating a list called unstablePackages
          "codex"
          "claude-code"
          "opencode"
        ];
        # i have to add netbird here because ssh isn't enabled otherwise
        # netbird on nixpkgs-unstable is >1yr old somehow
        netbirdOverride = pkgsUnstable.netbird.overrideAttrs (old: { # inside of pkgsUnstable is a thing called netbird, inside of netbird it uses a build system. that build system allows me to use overrideAttrs. it's a little counter-intuitive, because you'd expect "overrideAttrs" being after "netbird" means that there's something inside of "netbird" called "overrideAttrs", and, there kind of is, technically. but it's two more layers down inside of customisation.nix, and that's what allows you to do the following
          version = "0.75.0"; # this is used in its name in the nix store, as opposed to the following "rev" which is for git
          src = prev.fetchFromGitHub { # uses the fetchFromGitHub function from prev
            owner = "netbirdio";
            repo = "netbird";
            rev = "v0.75.0";
            hash = "sha256-1nFpeOWkWZIajjQU1jlSjQoxq+lyvR+rlsAxSV0vJZc=";
          };
          postPatch = ''
            substituteInPlace client/cmd/root.go \
              --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'
          '';
          proxyVendor = true;
          vendorHash = "sha256-KVGCV89qGHrg2GQVw6MnftQswbdihcqozptjf5vs5BA=";
        });
      in
      (builtins.listToAttrs (map (name: { # runs builtins.listToAttrs on what's derived from running the following function onto unstablePackages
        inherit name; # name = name, basically "rec" on attribute sets for functions instead, makes the "name" key in the name/value pair that listToAttrs requires equal to whatever's passed to "map"
        value = pkgsUnstable.${name}; # value = pkgsUnstable.name, easy to comprehend. the ${} makes it so it's referring to the "name" defined inside of this function, instead of something called "name" inside of pkgsUnstable
      }) unstablePackages)) // { # finally the attribute set the function defined above is being applied to
        netbird = netbirdOverride; # makes the "netbird" package equal to "netbirdOverride" defined above
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
