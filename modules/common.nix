{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  nix.settings.download-buffer-size = 134217728;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "lcd" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    btop
    git
    tmux
    python3
  ];

  programs.zsh.enable = true;

  networking.networkmanager.enable = true;
  virtualisation.oci-containers.backend = "podman";

  # this needs to be added so docker tools can find podman equivalent
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;

  systemd.timers."site-pull" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "10m";
        Unit = "site-pull.service";
      };
  };

  systemd.services."site-pull" = {
    # make sure git & python is available
    path = [ pkgs.git pkgs.python3 ];
    script = ''python3 /home/lcd/.config/nixos-config/scripts/site-pull.py'';
    serviceConfig = {
      Type = "oneshot";
      User = "lcd";
    };
  };

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

  users.users.lcd = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    users = [ "lcd" ];
    keepEnv = true;
    persist = true;
  }];
}
