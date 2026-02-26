{ config, ... }:
{

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/openwebui 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.openwebui = {
    image = "ghcr.io/open-webui/open-webui:main";
    extraOptions = [
      "--network=homelab"
    ];
    ports = [
      "3000:52320"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/home/lcd/containers/openwebui:/app/backend/data"
    ];
  };
}
