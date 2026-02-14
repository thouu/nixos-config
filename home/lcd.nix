{ config, pkgs, ... }:

{
  home.username = "lcd";
  home.homeDirectory = "/home/lcd";

  home.stateVersion = "24.11";

  home.packages = [
    pkgs.eza
    pkgs.fastfetch
    pkgs.tree
    pkgs.tealdeer
    pkgs.sops
    pkgs.awscli2
    pkgs.dig
    pkgs.fzf
    pkgs.ripgrep
    pkgs.zed-editor
    pkgs.claude-code
    pkgs.codex
    pkgs.opencode
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {

  };

  home.sessionVariables = {
    # EDITOR = "emacs";
    EDITOR = "vim";
    # Use this AWS profile by default so aws CLI works without prompts
    AWS_PROFILE = "censored";
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.keyFile = "/home/lcd/.config/sops/age/keys.txt";
  sops.secrets.openai_api_key = {};
  sops.secrets.anthropic_api_key = {};
  # Provision AWS CLI credentials and config from SOPS-managed secrets
  sops.secrets.aws_credentials = {
    # Writes the decrypted credentials to the AWS default location
    path = "${config.home.homeDirectory}/.aws/credentials";
    mode = "0600";
  };
  sops.secrets.aws_config = {
    path = "${config.home.homeDirectory}/.aws/config";
    mode = "0600";
  };
  sops.secrets.github_credentials = {
    path = "/home/lcd/.config/git/credentials";
    mode = "0600";
  };

  programs.home-manager.enable = true;
  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
  };

  programs.git = {
    enable = true;
    userName = "thou";
    userEmail = "nothou@proton.me";
    extraConfig = {
      init.defaultBranch = "main";

      credential = {
        helper = "store --file=${config.sops.secrets.github_credentials.path}";
        username = "thouu";
        "https://github.com" = { username = "thouu"; };
      };
      url = {
        "https://thouu@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      safe = {
        directory = "/home/lcd/.config/nixos-config";
      };
    };
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    autosuggestion.highlight = "fg=#8d8f9e";
    history.size = 999999;
    history.save = 9223372036854775807;
    history.append = true;
    history.extended = true;
    history.ignoreDups = true;
      initContent = ''
        autoload -U colors && colors
        PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
        export OPENAI_API_KEY="$(cat ${config.sops.secrets.openai_api_key.path})"
        export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic_api_key.path})"
      '';
    shellAliases = {
      ls = "eza -al --icons --color=always --group-directories-first";
      cd = "z";
      tree = "tree -C";
      neofetch = "fastfetch";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
