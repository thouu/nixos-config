{ config, ... }:

let
  mylar_netbird_ip = "100.126.231.177";
  is_mylar = config.networking.hostName == "mylar";
  db_host = if is_mylar then "postgres" else mylar_netbird_ip;
  host_port = if is_mylar then "52321" else "52320";

in
{
  sops.defaultSopsFile = ../home/secrets/secrets.yaml;

  sops.secrets = {
    encoded_postgres_password = {};
  };

  sops.templates."openwebui.env".content =
    "DATABASE_URL=postgresql://openwebui:${config.sops.placeholder.encoded_postgres_password}@${db_host}:5432/openwebui\n";

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/openwebui 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.openwebui = {
    image = "ghcr.io/open-webui/open-webui:main";
    extraOptions = [ "--network=homelab" ];
    ports = [ "${host_port}:52320" ];
    environmentFiles = [
      config.sops.templates."openwebui.env".path
    ];
    environment = {
      PORT = "52320";
    };
    volumes = [
      "/home/lcd/containers/openwebui:/app/backend/data"
    ];
  };
}
