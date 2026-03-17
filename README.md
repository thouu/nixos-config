# thou's nixos config

This is a NixOS configuration regarding two hosts, `tweed` and `mylar`.

The configuration integrates sops-nix for secrets management, ACME via Cloudflare, WireGuard (for a friend of mine who needs a US residental IP), & Docker via OCI containers. `mylar` has multiple backup services, designed around maintaining availability in the case of a power/internet outage on `tweed`'s end.

`flake.nix` uses a selective unstable overlay to pull specific packages (like `opencode`) from `nixpkgs-unstable`, while keeping the rest of the packages on the stable branch. There's also a manual version override for Netbird, because its version on `nixpkgs-unstable` was >1yr old and it made more sense to get it from Git directly.

`tweed` is a virtual machine running under a Proxmox host on a repurposed Dell Latitude e7440.

`mylar` is a VPS hosted on Oracle Cloud Infrastructure using their free tier. It has 4 ARM cores, and 24GB of RAM.

- `tweed` hosts the following:
  - [thou.sh](https://thou.sh)
  - [swagc.at](https://swagc.at)
  - Open WebUI
  - Pi-hole
  - qBittorrent
  - NetAlertX
  - WireGuard
- `mylar` hosts the following:
  - [thou.sh](https://thou.sh) (failover)
  - [swagc.at](https://swagc.at) (failover)
  - Open WebUI (failover)
  - PostgreSQL
  - WireGuard Proxy (routes tweed traffic)

 `tweed` & `mylar` are connected to the same Netbird VPN, and everything public routes through proxies on `mylar` back to `tweed`. If `tweed` is down, it fails over to `mylar`'s own standby containers.

 OpenWebUI on both `tweed` and `mylar` utilize `mylar`'s PostgreSQL server.

 ```
[lcd@tweed ~/.config/nixos-config]$ tree
.
├── containers
│   ├── gluetun.nix
│   ├── homarr.nix
│   ├── netalertx.nix
│   ├── nginx-mylar.nix
│   ├── nginx-tweed.nix
│   ├── openwebui.nix
│   ├── pihole.nix
│   ├── postgres.nix
│   └── qbittorrent.nix
├── flake.lock
├── flake.nix
├── home
│   ├── lcd.nix
│   └── secrets
│       └── secrets.yaml
├── hosts
│   ├── mylar
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── tweed
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules
│   ├── common.nix
│   ├── netbird.nix
│   ├── wireguard-mylar.nix
│   └── wireguard-tweed.nix
└── scripts
    └── site-pull.py

9 directories, 22 files
```
