{lib, ...}:

let
  blocklists = {
    "Hagezi MultiULTIMATE" = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt";
    "Hagezi MultiLIGHT" = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/light.txt";
    "Social Media" = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists/main/adblock/social.txt";
    "Mini Hagezi Threat Intelligence Feed" = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.mini.txt";
    "Medium Hagezi Threat Intelligence Feed" = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.medium.txt";
    "Domains with 7-day registration" = "https://raw.githubusercontent.com/hagezi/nrd/main/adblock/dga7.txt";
  };

in
{
  sops.secrets.pihole_env = {
    sopsFile = ../home/secrets/secrets.yaml;
  };
  services = {
    pihole-ftl = {
      enable = true;
      lists = builtins.attrValues (builtins.mapAttrs(name: value: {
        url = "${value}";
        type = "block";
        enabled = true;
        description = "${name}";
      }) blocklists);
      openFirewallDNS = true;
      openFirewallWebserver = true;
      settings = {
        dns = {
          upstreams = [ "1.1.1.1" "1.0.0.1" ];
          hosts = [
            "10.0.0.115 homarr.thou.sh"
            "10.0.0.115 pihole.thou.sh"
            "10.0.0.115 thou.sh"
            "10.0.0.115 netalertx.thou.sh"
            "10.0.0.115 qbt.thou.sh"
          ];
          listeningMode = "ALL";
        };
        database.maxDBdays = 365;
        database.network.expire = 90;
        webserver = {
          port = 8053;
          interface.theme = "default-darker";
        };
      };
    };
    pihole-web = {
      enable = true;
      ports = [ 8053 ];
    };
  };
}
