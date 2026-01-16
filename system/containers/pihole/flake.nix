{
  description = "PiHole OCI container";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = import ./module.nix;
  };
}
