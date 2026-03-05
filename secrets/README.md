# secrets/

Encrypted secrets managed by [agenix](https://github.com/ryantm/agenix). Each `.age` file is encrypted to the host's SSH key and (optionally) admin age keys, so only the target machine and authorized admins can decrypt them.

## Secret files

| File | Contents | Used by |
|------|----------|---------|
| `mysql-root.age` | MySQL root password | MariaDB |
| `mysql-mediawiki.age` | MediaWiki DB password | MediaWiki, MariaDB |
| `mysql-pydonate.age` | pydonate DB password | pydonate, MariaDB |
| `stripe-keys.age` | Stripe API keys (key, secret, product, donate secret) | pydonate |
| `prometheus-auth.age` | Bcrypt password hash for Prometheus basic auth | Caddy |
| `grafana-admin.age` | Grafana admin password | Grafana |

## Setup

1. Generate an ed25519 SSH host key on the target machine:
   ```sh
   ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   ```

2. Derive the age public key:
   ```sh
   nix-shell -p ssh-to-age --run 'ssh-keyscan <host> | ssh-to-age'
   ```

3. Put the age public key in `secrets.nix` as the `hostKey`.

4. Encrypt each secret:
   ```sh
   nix run github:ryantm/agenix -- -e mysql-root.age
   ```

5. After adding a new key to `secrets.nix`, re-key all secrets:
   ```sh
   nix run github:ryantm/agenix -- -r
   ```

Secrets are decrypted at system activation time and placed in `/run/agenix/<name>` (a tmpfs, never written to disk in plaintext).
