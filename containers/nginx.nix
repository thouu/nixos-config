{ config, ... }:
{

  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/nginx/etc-nginx 0755 lcd users -"
    "d /home/lcd/containers/nginx/var-www 0755 lcd users -"
  ];

  virtualisation.oci-containers.containers.nginx = {
    image = "nginx";
    ports = [
      "80:80/tcp"
      "443:443/tcp"
    ];
    volumes = [
      "/home/lcd/containers/nginx/etc-nginx:/etc/nginx"
      "/home/lcd/containers/nginx/sites:/sites"
    ];
  };
}
