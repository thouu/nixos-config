{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common.nix
    ../../modules/netbird.nix
    ../../modules/wireguard-mylar.nix

    # containers
    ../../containers/nginx-mylar.nix
    ../../containers/postgres.nix
    ../../containers/openwebui.nix
  ];

  networking.hostName = "mylar";

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.systemPackages = with pkgs; [
    jdk21_headless
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    users.lcd = import ../../home/lcd.nix;
  };

  services.fail2ban = {
    enable = true;
  };

  services.openssh = {
    ports = [ 44704 ];
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
        "thou.sh"
        "swagc.at"
        "ai.thou.sh"
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
