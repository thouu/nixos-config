{ config, ...}:
{
  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/qbittorrent 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.qbittorrent = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    extraOptions = [
      "--network=container:gluetun"
    ];
    volumes = [
      "/home/lcd/containers/qbittorrent/config:/config"
      "/home/lcd/containers/qbittorrent/torrent-files:/torrent-files"
    ];
    environment = {
      TZ = "America/Los_Angeles";
      WEBUI_PORT = "30025";
      TORRENTING_PORT = "57964";
    };
  };
}
