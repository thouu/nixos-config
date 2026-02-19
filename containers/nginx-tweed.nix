{ config, ... }:
let
  nginxConf = ''
    events {
      worker_connections 1024;
    }

    http {
      server {
        listen 80;
        server_name homarr.thou.sh pihole.thou.sh;

        return 301 https://$host$request_uri;
      }

      server {
        listen 443 ssl;
        server_name homarr.thou.sh;

        ssl_certificate /etc/ssl/acme/homarr.thou.sh/fullchain.pem;
        ssl_certificate_key /etc/ssl/acme/homarr.thou.sh/key.pem;

        location / {
          proxy_pass http://homarr:7575;
        }
      }

      server {
        listen 443 ssl;
        server_name pihole.thou.sh;

        ssl_certificate /etc/ssl/acme/pihole.thou.sh/fullchain.pem;
        ssl_certificate_key /etc/ssl/acme/pihole.thou.sh/key.pem;

        location / {
          proxy_pass http://pihole:80;
        }
      }
    }
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/nginx-tweed/etc-nginx 0755 lcd users -"
    "d /home/lcd/containers/nginx-tweed/sites 0755 lcd users -"
    "d /home/lcd/containers/nginx-tweed/logs 0755 lcd users -"
  ];

  environment.etc."nginx-tweed/nginx.conf".text = nginxConf;

  virtualisation.oci-containers.containers.nginx = {
    image = "nginx";
    dependsOn = [ "homarr" ];
    extraOptions = [
      "--network=homelab"
    ];
    ports = [
      "80:80/tcp"
      "443:443/tcp"
    ];
    volumes = [
      "/etc/nginx-tweed/nginx.conf:/etc/nginx/nginx.conf:ro"
      "/home/lcd/containers/nginx-tweed/logs:/var/log/nginx"
      "/home/lcd/containers/nginx-tweed/sites:/sites"
      "/var/lib/acme/homarr.thou.sh:/etc/ssl/acme/homarr.thou.sh:ro"
      "/var/lib/acme/pihole.thou.sh:/etc/ssl/acme/pihole.thou.sh:ro"
    ];
  };
}
