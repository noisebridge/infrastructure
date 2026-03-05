# Noisebridge Infrastructure

NixOS configuration for Noisebridge's internet-facing services, running on a single self-hosted machine at a colocation facility. Managed declaratively with Nix Flakes.

## Code of Conduct

Noisebridge infrastructure members follow the Rack Code of Conduct.

### Security

Noisebridge infrastructure members protect the privacy and security of our systems and members.

* Secrets are encrypted with [agenix](https://github.com/ryantm/agenix) and checked into the repo.
* The host SSH key is required to decrypt secrets at activation time.
* Care needs to be taken when handling Issues and PRs to protect the privacy of members.

### Reliability

Noisebridge infrastructure members keep services up and running.

* Test changes as best as you can before deploying to production.
* Improve monitoring as you go.
* Think first, deploy once.
* Rollback quickly when things fail (NixOS makes this trivial).

### Reproducibility

Noisebridge infrastructure members should ensure that changes are made in a way
that is reproducible for others.

* All changes to infrastructure should be checked into this repo.
* Changes should be made with Pull Requests so that they can be reviewed.
* The entire system is declarative — `nixos-rebuild switch` produces the same result every time.

By documenting how systems are built in this repo, if a disk fails or a machine
walks off, a full rebuild from scratch is a single `nixos-install` away.

## Services

| Service | Purpose |
|---------|---------|
| **MediaWiki** | Main wiki at noisebridge.net |
| **CoreDNS** | Authoritative DNS for noisebridge.net/com/io/org, noisetor.net |
| **Caddy** | Reverse proxy, automatic Let's Encrypt TLS, rate limiting |
| **Prometheus** | Metrics collection |
| **Grafana** | Monitoring dashboards |
| **pydonate** | Donation app (Stripe integration) |
| **MariaDB** | Database for MediaWiki + pydonate |
| **Memcached** | Caching for MediaWiki |
| **Blackbox exporter** | HTTP/SMTP uptime probes |
| **Node exporter** | Machine CPU/RAM/disk metrics |
| **MyDumper** | Automated MySQL backups (28-day retention) |

## Repository Structure

```
.
├── flake.nix              # Flake entry point — inputs, outputs, nixosConfigurations
├── flake.lock             # Pinned dependency versions
├── hosts/noisebridge/     # Host-specific config (hardware, boot, networking, disk layout)
├── modules/               # Service modules (one per service)
├── dns-zones/             # Authoritative DNS zone files
├── secrets/               # agenix-encrypted secrets
└── overlays/              # Nix package overlays (custom Caddy build)
```

## Prerequisites

* [Nix](https://nixos.org/download.html) with flakes enabled
* Access to the host SSH key (for decrypting secrets with agenix)

## Deploying

### Full system rebuild (on the machine)

```sh
sudo nixos-rebuild switch --flake .#noisebridge
```

### Remote deployment with deploy-rs

```sh
nix run github:serokell/deploy-rs -- .#noisebridge
```

### Building without deploying

```sh
nix build .#nixosConfigurations.noisebridge.config.system.build.toplevel
```

## Managing Secrets

Secrets are encrypted with [agenix](https://github.com/ryantm/agenix). The key mappings are in `secrets/secrets.nix`.

```sh
# Edit an existing secret
nix run github:ryantm/agenix -- -e secrets/mysql-root.age

# Re-key all secrets (after adding a new admin key or host key)
nix run github:ryantm/agenix -- -r
```

Secrets decrypt at activation time to `/run/agenix/<name>`.

## Joining

See https://discuss.noisebridge.info/c/guilds/rack for guidance, specifically the sticky.

To join the infrastructure team, create a PR adding your GitHub username to `MAINTAINERS.md` and your account to `modules/users.nix`.

## Maintainers

* [SuperQ](https://github.com/SuperQ)
* [rizend](https://github.com/rizend)
* [Kevin](https://github.com/kevinjos)
* [Tim](https://github.com/allyourbasepair)
