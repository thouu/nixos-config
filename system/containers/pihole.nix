{ ... }:
{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "8053:80/tcp"  # web UI - using 8053 to avoid conflicts
    ];
    volumes = [
      "/var/lib/pihole/etc-pihole:/etc/pihole"
      "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    environment = {
      TZ = "America/Los_Angeles";
      WEBPASSWORD = "changeme";  # swap this for sops
    };
  };
}
