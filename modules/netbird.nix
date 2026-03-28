{ config, pkgs, ... }:

let
  is_mylar = config.networking.hostName == "mylar";
  netbird_listen_port = if is_mylar then "51821" else "51820";

in
{
  # netbird
  sops.secrets.netbird_setup_key = {
    sopsFile = ../home/secrets/secrets.yaml;
  };

  services.netbird.enable = true;
  systemd.services.netbird.path = [ pkgs.shadow ];

  systemd.services.netbird-setup = {
    description = "NetBird initial setup";
    after = [ "network-online.target" "netbird.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.netbird ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      SETUP_KEY=$(cat ${config.sops.secrets.netbird_setup_key.path} | tr -d '\n')
      netbird up \
      --setup-key "$SETUP_KEY" \
      --allow-server-ssh \
      --enable-ssh-local-port-forwarding \
      --enable-ssh-remote-port-forwarding \
      --listen-port ${netbird_listen_port}
    '';
  };
}
