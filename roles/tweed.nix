{ inputs, config, lib, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/netbird.nix
    ../modules/wireguard-tweed.nix

    # containers
    ../containers/pihole.nix
    ../containers/homarr.nix
    ../containers/nginx-tweed.nix
    ../containers/netalertx.nix
    #../containers/openwebui.nix
    ../containers/gluetun.nix
    ../containers/qbittorrent.nix
  ];

  networking.hostName = "tweed";

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    users.lcd = import ../../home/lcd.nix;
  };

  sops = {
    defaultSopsFile = ../../home/secrets/secrets.yaml;
    age.keyFile = "/home/lcd/.config/sops/age/keys.txt";
    secrets.acme_cloudflare_env = {
      owner = "acme";
      group = "acme";
      mode = "0400";
    };
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
        reloadServices = [ "docker-nginx.service" ];
      });
    };
}
