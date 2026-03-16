{ config, ... }:
{
  sops.secrets.pihole_env = {
    sopsFile = ../home/secrets/secrets.yaml;
  };

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/pihole/etc-pihole 0755 lcd users -"
    "d /home/lcd/containers/pihole/etc-dnsmasq.d 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    extraOptions = [
      "--network=homelab"
    ];
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "8053:80/tcp"
    ];
    volumes = [
      "/home/lcd/containers/pihole/etc-pihole:/etc/pihole"
      "/home/lcd/containers/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    environmentFiles = [
      config.sops.secrets.pihole_env.path
    ];
    environment = {
      TZ = "America/Los_Angeles";
      PIHOLE_UID = "1000";
      PIHOLE_GID = "1000";
    };
  };
}
