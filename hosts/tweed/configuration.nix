{ inputs, config, lib, ... }:

{
  # what tweed is (as opposed to what tweed does (defined in roles/tweed.nix))

  imports = [
    ./hardware-configuration.nix
  ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 12288;
  }];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
