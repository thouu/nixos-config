{ config, ... }:
{
  sops.secrets.SECRET_ENCRYPTION_KEY = {
    sopsFile = ../home/secrets/secrets.yaml;
  };

  sops.templates."homarr.env".content =
    "SECRET_ENCRYPTION_KEY=${config.sops.placeholder.SECRET_ENCRYPTION_KEY}\n";

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/homarr/appdata 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/homarr-labs/homarr:latest";
    extraOptions = [
      "--network=homelab"
    ];
    ports = [
      "7575:7575"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/home/lcd/containers/homarr/appdata:/appdata"
    ];
    environmentFiles = [
      config.sops.templates."homarr.env".path
    ];
    environment = {

    };
  };
}
