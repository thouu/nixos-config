{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/netalertx/data 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.netalertx = {
    image = "ghcr.io/netalertx/netalertx:latest";
    extraOptions = [
      "--network=host"
      "--cap-add=NET_RAW"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_BIND_SERVICE"
      "--tmpfs=/tmp:mode=1700"
    ];
    volumes = [
      "/home/lcd/containers/netalertx/data:/data"
      "/etc/localtime:/etc/localtime"
    ];
    environment = {
      PORT = "20211";
      APP_CONF_OVERRIDE = ''{"GRAPHQL_PORT":"20214"}'';
      LOADED_PLUGINS = ''["ARPSCAN","AVAHISCAN","DIGSCAN","NBTSCAN","NSLOOKUP"]'';
    };
  };
}
