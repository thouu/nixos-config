{ config, pkgs, ... }:

{
  sops.secrets.wg_tweed_key = {};

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.nat = {
    enable = true;
    internalInterfaces = [ "wg0" ];
    externalInterface = "ens3";
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.2/24" ];
    privateKeyFile = config.sops.secrets.wg_tweed_key.path;

    peers = [
      {
        # mylar
        publicKey = "6X6tjJ3rF8R4SLUShBkV1njjxbeFlrxGSyZ6UWpTLw0=";
        endpoint = "wg4b.thou.sh:44019";
        allowedIPs = [ "10.100.0.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
