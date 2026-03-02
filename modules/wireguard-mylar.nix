{ config, pkgs, ... }:

{
  sops.secrets.wg_mylar_key = {};

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.trustedInterfaces = [ "wg0" ];
  networking.firewall.allowedUDPPorts = [ 44019 ];
  networking.firewall.checkReversePath = "loose";

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = 44019;
    privateKeyFile = config.sops.secrets.wg_mylar_key.path;
    table = "off";

    postUp = ''
      ${pkgs.iproute2}/bin/ip rule add iif wg0 table main suppress_prefixlength 0 priority 90
      ${pkgs.iproute2}/bin/ip rule add iif wg0 table 200 priority 100
      ${pkgs.iproute2}/bin/ip route add default dev wg0 table 200
    '';

    postDown = ''
      ${pkgs.iproute2}/bin/ip rule del iif wg0 table main suppress_prefixlength 0 priority 90 || true
      ${pkgs.iproute2}/bin/ip rule del iif wg0 table 200 priority 100 || true
      ${pkgs.iproute2}/bin/ip route del default dev wg0 table 200 || true
    '';

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
