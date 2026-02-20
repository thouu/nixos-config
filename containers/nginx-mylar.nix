{ config, ... }:
let
  nginxConf = ''
    events {
      worker_connections 1024;
    }
    http {
      include /etc/nginx/mime.types; # this needs to be here otherwise css & js wont work

      upstream thou_site {
        server 100.126.102.20:80;
        server 127.0.0.1:8080 backup;
      }

      server {
        listen 80;
        server_name thou.sh www.thou.sh;
        return 301 https://$host$request_uri;
      }

      server {
        listen 443 ssl;
        server_name thou.sh www.thou.sh;

        ssl_certificate /etc/ssl/acme/thou.sh/fullchain.pem;
        ssl_certificate_key /etc/ssl/acme/thou.sh/key.pem;

        location / {
          proxy_pass http://thou_site;
          proxy_set_header Host $host;
        }
      }

      server {
        listen 8080;
        root /sites/thou.sh;
        index index.html index.htm;
      }
    }
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/nginx-mylar/etc-nginx 0755 lcd users -"
    "d /home/lcd/containers/nginx-mylar/sites 0755 lcd users -"
    "d /home/lcd/containers/nginx-mylar/logs 0755 lcd users -"
  ];

  environment.etc."nginx-mylar/nginx.conf".text = nginxConf;

  virtualisation.oci-containers.containers.nginx = {
    image = "nginx";
    ports = [
      "80:80/tcp"
      "443:443/tcp"
    ];
    volumes = [
      "/etc/nginx-mylar/nginx.conf:/etc/nginx/nginx.conf:ro"
      "/home/lcd/containers/nginx-mylar/logs:/var/log/nginx"
      "/home/lcd/containers/nginx-mylar/sites:/sites"
      "/var/lib/acme/thou.sh:/etc/ssl/acme/thou.sh:ro"
    ];
  };
}
