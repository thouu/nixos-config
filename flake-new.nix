{
  description = "multi-host nixos system, with swatch live testing framework";
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
    unstableOverlay: final: prev:
      let
        nixpkgsUnstable = import nixpkgs-unstable {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
        unstablePackages = [
          "codex"
          "claude-code"
          "opencode"
        ];

}
