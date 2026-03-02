{ config, pkgs, ... }:

{
  sops.secrets.wg_mylar_key = {};

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.allowedUDPPorts = [ 44019 ];

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = 44019;
    privateKeyFile = config.sops.secrets.wg_mylar_key.path;
    table = "off";

    peers = [
      {
        # tweed
        publicKey = "7IyvGUvxpKCjF5mVQ+M6h8jSyN9cYnmIjB+vUgI2mzs=";
        allowedIPs = [ "0.0.0.0/0" ];
      }
      {
        # user
        publicKey = "GEaZAtlkxYwAdNsS466VtqnjGBoivcBBEfsYks5ASC0=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };
}
