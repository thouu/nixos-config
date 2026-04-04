{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

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
        credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
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
