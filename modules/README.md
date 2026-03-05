# modules/

NixOS service modules. Each file configures one logical service or concern.

| Module | Service | Listens on |
|--------|---------|------------|
| `caddy.nix` | Reverse proxy with automatic TLS and rate limiting | `:80`, `:443` |
| `coredns.nix` | Authoritative DNS (noisebridge.net/com/io/org, noisetor.net) | `:53` (tcp+udp) |
| `mediawiki.nix` | MediaWiki + Memcached | PHP-FPM socket, memcached `:11211` |
| `mysql.nix` | MariaDB + MyDumper daily backups | `127.0.0.1:3306` |
| `prometheus.nix` | Prometheus + node exporter + blackbox exporter | `127.0.0.1:9090`, `:9100`, `:9115` |
| `grafana.nix` | Grafana dashboards (Prometheus datasource) | `127.0.0.1:3000` |
| `pydonate.nix` | Donation app (Flask + Stripe) | `127.0.0.1:8888` |
| `backup.nix` | ZFS snapshots via Sanoid (hourly/daily/monthly retention) | n/a |
| `security.nix` | Firewall, fail2ban, SSH hardening, kernel sysctl | n/a |
| `users.nix` | Admin accounts with SSH keys from GitHub | n/a |

All modules are imported by `flake.nix` and compose together on the single host.

## Adding a new service

1. Create `modules/<service>.nix`.
2. Add it to the `modules` list in `flake.nix`.
3. If it needs secrets, add entries in `secrets/secrets.nix` and encrypt them with agenix.
4. If it needs a Caddy vhost, add a `virtualHosts` entry in `modules/caddy.nix`.
