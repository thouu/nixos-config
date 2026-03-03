{ config, ... }:
{
  sops.defaultSopsFile = ../home/secrets/secrets.yaml;

  sops.secrets = {
    gluetun_wg_private_key = {};
    gluetun_wg_preshared_key = {};
  };

  sops.templates."gluetun.env".content = ''
    WIREGUARD_PRIVATE_KEY=''${config.sops.placeholder.gluetun_wg_private_key}
    WIREGUARD_PRESHARED_KEY=''${config.sops.placeholder.gluetun_wg_preshared_key}
  '';

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/gluetun 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.gluetun = {
    image = "qmcgaw/gluetun:latest";
    extraOptions = [
      "--network=homelab"
    ];
    ports = [
      "30025:30025"
      "57964:57964"
      "57964:57964/udp"
    ];
    volumes = [
      "/home/lcd/containers/gluetun:/gluetun"
    ];
    environmentFiles = [
      config.sops.templates."gluetun.env".path
    ];
    environment = {
      VPN_SERVICE_PROVIDER = "airvpn";
      VPN_TYPE = "wireguard";
      WIREGUARD_ADDRESSES = "10.183.80.88/32";
      TZ = "America/Los_Angeles";
      UPDATER_PERIOD = "24h";
    };
  };
}
