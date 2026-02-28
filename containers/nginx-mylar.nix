{ config, ... }:
let
  tweed_netbird_ip = "100.126.102.20";

  nginxConf = ''
    events {
      worker_connections 1024;
    }
    http {
      include /etc/nginx/mime.types; # this needs to be here otherwise css & js wont work

      types {
        text/css css;
        application/javascript js;
      }

      # rate limiting
      limit_req_zone $binary_remote_addr zone=general:10m rate=30r/s;

      # openwebui

      upstream openwebui {
        server ${tweed_netbird_ip}:52320;
        server 127.0.0.1:52321 backup;
      }

      server {
        listen 443 ssl;
        server_name owui.thou.sh;
        ssl_certificate /etc/ssl/acme/owui.thou.sh/fullchain.pem;
        ssl_certificate_key /etc/ssl/acme/owui.thou.sh/key.pem;

        # rate limiting
        limit_req zone=general burst=20 nodelay;

        location / {
          proxy_pass http://openwebui;
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;

          # failover
          proxy_connect_timeout 5s;
          proxy_read_timeout 60s;
          proxy_send_timeout 60s;
        }
      }

      # thou.sh

      upstream thou_site {
        server ${tweed_netbird_ip}:80;
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

        # rate limiting
        limit_req zone=general burst=20 nodelay;

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

      # swagc.at

      upstream swagcat_site {
        server ${tweed_netbird_ip}:80;
        server 127.0.0.1:8081 backup;
      }

      server {
        listen 80;
        server_name swagc.at www.swagc.at;
        return 301 https://$host$request_uri;
      }

      server {
        listen 443 ssl;
        server_name swagc.at www.swagc.at;

        ssl_certificate /etc/ssl/acme/swagc.at/fullchain.pem;
        ssl_certificate_key /etc/ssl/acme/swagc.at/key.pem;

        # rate limiting
        limit_req zone=general burst=20 nodelay;

        location / {
          proxy_pass http://swagcat_site;
          proxy_set_header Host $host;
        }
      }

      server {
        listen 8081;
        root /sites/swagc.at;
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
      "/var/lib/acme/swagc.at:/etc/ssl/acme/swagc.at:ro"
    ];
  };
}
