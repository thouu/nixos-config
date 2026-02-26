# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/common.nix
    ../../modules/netbird.nix

    # containers
    ../../containers/pihole.nix
    ../../containers/homarr.nix
    ../../containers/nginx-tweed.nix
    ../../containers/openwebui.nix
    ../../containers/netalertx.nix
  ];

  networking.hostName = "tweed"; # Define your hostname.

  networking.firewall.allowedTCPPorts = [ 20211 20214 ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    users.lcd = import ../../home/lcd.nix;
  };

  # import the home-manager sops to be system-wide for containers
  sops.defaultSopsFile = ../../home/secrets/secrets.yaml;
  sops.age.keyFile = "/home/lcd/.config/sops/age/keys.txt";

  sops.secrets.acme_cloudflare_env = {
    owner = "acme";
    group = "acme";
    mode = "0400";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nothou@proton.me";
    certs."homarr.thou.sh" = {
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
      reloadServices = [ "docker-nginx.service" ];
    };
    certs."pihole.thou.sh" = {
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
      reloadServices = [ "docker-nginx.service" ];
    };
    certs."netalertx.thou.sh" = {
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
      reloadServices = [ "docker-nginx.service" ];
    };
  };

  # i need to add this to make sure nginx can point to homarr
  systemd.services.homelab-docker-network = {
    description = "make homelab docker network";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    before = [ "docker-homarr.service" "docker-nginx.service" ];
    requiredBy = [ "docker-homarr.service" "docker-nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.docker ];
    script = ''
      if ! docker network inspect homelab >/dev/null 2>&1; then
        docker network create homelab >/dev/null
      fi
    '';
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 12288;
  } ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
