{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/qbittorrent 0755 lcd users -"
    "d /home/lcd/containers/qbittorrent/config 0755 lcd users -"
    "d /home/lcd/containers/qbittorrent/torrent-files 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.qbittorrent = {
    image = "linuxserver/qbittorrent";
    extraOptions = [
      "--network=container:gluetun"
    ];
    dependsOn = [ "gluetun" ];
    volumes = [
      "/home/lcd/containers/qbittorrent/config:/config"
      "/home/lcd/containers/qbittorrent/torrent-files:/torrent-files"
    ];
    environment = {
      # on nixos default uid is 1000 & default gid is 1000
      # this ensures lcd's access to torrented files
      PUID = "1000";
      PGID = "100";
      TZ = "America/Los_Angeles";
      WEBUI_PORT = "30025";
      TORRENTING_PORT = "57964";
    };
  };
}
