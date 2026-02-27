{ config, ... }:
{
  sops.secrets.POSTGRES_PASSWORD = {
    sopsFile = ../home/secrets/secrets.yaml;
  };

  sops.templates."postgres.env".content =
    "POSTGRES_PASSWORD=${config.sops.placeholder.POSTGRES_PASSWORD}\n";

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/postgres/postgres-data 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.postgres = {
    image = "postgres:18-trixie";
    extraOptions = [
      "--network=homelab"
    ];
    ports = [
      "100.126.141.19:5432:5432"
    ];
    volumes = [
      "/home/lcd/containers/postgres/postgres-data:/var/lib/postgresql"
    ];
    environmentFiles = [
      config.sops.templates."postgres.env".path
    ];
    environment = {
      POSTGRES_DB = "openwebui";
      POSTGRES_USER = "openwebui";
    };
  };
}
