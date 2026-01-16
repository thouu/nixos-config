{ config, lib, ... }:

with lib;

{
  options.services.pihole = {
    enable = mkEnableOption "PiHole DNS server";

    password = mkOption {
      type = types.str;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/home/lcd/container-data/pihole";
    };
  };

  config = mkIf config.services.pihole.enable {
    virtualisation.oci-containers.containers.pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "73927:80/tcp"
        "53:53/tcp"
        "53:53/udp"
      ];
      environment = {
        WEBPASSWORD = config.services.pihole.password;
        TZ = config.time.timeZone or "UTC";
      };
      volumes = [
        "${config.services.pihole.dataDir}/etc-pihole:/etc/pihole:rw"
        "${config.services.pihole.dataDir}/etc-dnsmasq.d:/etc/dnsmasq.d:rw"
      ];
      autoStart = true;
    };

    # make it so i have access
    systemd.tmpfiles.rules = [
      "d ${config.services.pihole.dataDir} 0755 lcd lcd"
      "d ${config.services.pihole.dataDir}/etc-pihole 0755 lcd lcd"
      "d ${config.services.pihole.dataDir}/etc-dnsmasq.d 0755 lcd lcd"
    ];

    networking.firewall.allowedTCPPorts = mkIf config.networking.firewall.enable [ 53 62753 ];
    networking.firewall.allowedUDPPorts = mkIf config.networking.firewall.enable [ 53 ];
  };
}
