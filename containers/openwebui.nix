{ config, pkgs, ... }:

sops.secrets.openwebui_db_url = {
  sopsFile = ../home/secrets/secrets.yaml;
};

let
  mylar_netbird_ip = "100.126.141.19";

  is_mylar = config.networking.hostName == "mylar";

  db_host = if is_mylar then "postgres" else mylar_netbird_ip;
  database_url = "postgresql://openwebui:${dbPassword}@${db_host}:5432/openwebui";

  host_port = if is_mylar then "52321" else "52320";

in
{
  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/openwebui 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.openwebui = {
    image = "ghcr.io/open-webui/open-webui:main";
    extraOptions = [ "--network=homelab" ];
    ports = [ "${host_port}:52320" ];
    environmentFiles = [
      config.sops.secrets.openwebui_db_url.path
    ];
    environment = {
      PORT = "52320";
      DATABASE_URL = database_url;
    };
    volumes = [
      "/home/lcd/containers/openwebui:/app/backend/data"
    ];
  };
}
