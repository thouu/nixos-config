{ inputs, config, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/common.nix
    ../../modules/netbird.nix
    ../../modules/wireguard-tweed.nix

    # containers
    ../../containers/pihole.nix
    ../../containers/homarr.nix
    ../../containers/nginx-tweed.nix
    ../../containers/netalertx.nix
    #../../containers/openwebui.nix
    ../../containers/gluetun.nix
    ../../containers/qbittorrent.nix
  ];

  networking.hostName = "tweed"; # Define your hostname.

  networking.firewall.allowedTCPPorts = [ 20211 20214 ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # im adding this because pihole wont work on podman otherwise
  # it's also recommended according to pihole docs
  # this might stop working come 26.05, because they're moving away from the "extraConfig" syntax
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNSStubListener=no
    '';
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

  security.acme =
    let
      acme_domains = [
        "homarr.thou.sh"
        "pihole.thou.sh"
        "netalertx.thou.sh"
        "qbt.thou.sh"
      ];
    in
    {
      acceptTerms = true;
      defaults.email = "nothou@proton.me";
      certs = lib.genAttrs acme_domains (_: {
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.acme_cloudflare_env.path;
        reloadServices = [ "podman-nginx.service" ];
      });
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
