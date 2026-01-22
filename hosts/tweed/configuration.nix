# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/common.nix
    ../../modules/server.nix
    ../../modules/netbird.nix

    # containers
    ../../containers/pihole.nix
    ../../containers/homarr.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "tweed"; # Define your hostname.

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    users.lcd = import ../../home/lcd.nix;
  };

  # import the home-manager sops to be system-wide for containers
  sops.defaultSopsFile = ../../home/secrets/secrets.yaml;
  sops.age.keyFile = "/home/lcd/.config/sops/age/keys.txt";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
