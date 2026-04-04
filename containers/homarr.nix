{ config, ... }:
{
  sops.defaultSopsFile = ../home/secrets/secrets.yaml;

  sops.secrets = {
    homarr_encryption_key = {};
  };

  sops.templates."homarr.env".content = ''
    SECRET_ENCRYPTION_KEY=${config.sops.placeholder.homarr_encryption_key}
  '';

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
      "/run/user/1000/podman/podman.sock:/var/run/docker.sock"
      "/home/lcd/containers/homarr/appdata:/appdata"
    ];
    environmentFiles = [
      config.sops.templates."homarr.env".path
    ];
  };
}
