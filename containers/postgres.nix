{ config, ... }:
{
  sops.secrets.POSTGRES_PASSWORD = {
    sopsFile = ../home/secrets/secrets.yaml;
  };

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/postgres/postgres-data 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.postgres = {
    image = "postgres/postgres:18-trixie";
    extraOptions = [
      "--network=homelab"
    ];
    ports = [
      "127.0.0.1:5432:5432"
    ];
    volumes = [
      "/home/lcd/containers/postgres/postgres-data:/var/lib/postgresql/data"
    ];
    environment = {
      POSTGRES_PASSWORD_FILE = config.sops.secrets.POSTGRES_PASSWORD.path;
    };
  };
}
