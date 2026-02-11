{ config, ... }:
let
  nginxConf = ''
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log warn;
    pid /var/run/nginx.pid;

    events {
      worker_connections 1024;
    }

    http {
      include /etc/nginx/mime.types;
      default_type application/octet-stream;

      log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

      access_log /var/log/nginx/access.log main;

      sendfile on;
      tcp_nopush on;
      tcp_nodelay on;
      keepalive_timeout 65;
      types_hash_max_size 2048;

      upstream homarr {
        server 10.0.0.115:7575;
      }

      server {
        listen 80;
        server_name homarr.thou.sh;

        location / {
          proxy_pass http://homarr;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;
          proxy_set_header Connection "";
        }
      }
    }
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /home/lcd/containers/nginx-tweed/etc-nginx 0755 lcd users -"
    "d /home/lcd/containers/nginx-tweed/var-www 0755 lcd users -"
    "d /home/lcd/containers/nginx-tweed/logs 0755 lcd users -"
  ];

  environment.etc."nginx-tweed/nginx.conf".text = nginxConf;

  virtualisation.oci-containers.containers.nginx = {
    image = "nginx";
    ports = [
      "80:80/tcp"
      "443:443/tcp"
    ];
    volumes = [
      "/etc/nginx-tweed/nginx.conf:/etc/nginx/nginx.conf:ro"
      "/home/lcd/containers/nginx-tweed/logs:/var/log/nginx"
      "/home/lcd/containers/nginx-tweed/sites:/sites"
    ];
  };
}
