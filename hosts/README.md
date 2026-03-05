# hosts/

Host-specific NixOS configurations. Each subdirectory is a machine.

## noisebridge/

The primary Noisebridge colo server. Contains:

| File | Purpose |
|------|---------|
| `default.nix` | Main host config — hostname, networking, boot loader, timezone, system packages, ZFS scrub, nix settings |
| `hardware-configuration.nix` | Hardware-specific kernel modules and firmware. Replace with output of `nixos-generate-config --show-hardware-config` on the actual machine. |
| `disk-config.nix` | Declarative disk layout using [disko](https://github.com/nix-community/disko). Defines a ZFS mirror across two NVMe drives with datasets for each service (`tank/mysql`, `tank/mediawiki`, `tank/prometheus`, `tank/grafana`, `tank/backups`). |

### Before first deploy

1. Replace the placeholder IPs in `default.nix` with the real colo addresses.
2. Set `networking.hostId` to the output of `head -c 8 /etc/machine-id` on the target.
3. Replace `hardware-configuration.nix` with the real hardware scan.
4. Verify the NVMe device paths in `disk-config.nix` match the actual hardware.
