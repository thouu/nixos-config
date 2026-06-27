{ inputs, config, lib, ... }:

{
  # what mylar is (as opposed to what mylar does (defined in roles/mylar.nix))

  imports = [
    ./hardware-configuration.nix
  ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 12288;
  }];

  system.stateVersion = "25.05"; # Did you read the comment?
}
