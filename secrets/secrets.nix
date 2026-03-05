# agenix secret definitions.
#
# Usage:
#   1. Generate an ed25519 SSH host key on the target machine:
#      ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
#
#   2. Derive the age public key:
#      nix-shell -p ssh-to-age --run 'ssh-keyscan <host> | ssh-to-age'
#
#   3. Put that public key below in `hostKey`.
#
#   4. Encrypt secrets:
#      cd nixos/secrets
#      agenix -e mysql-root.age
#
#   5. Secrets decrypt at activation to /run/agenix/<name>
#
let
  # Replace with the actual age public key derived from the host's SSH key.
  hostKey = "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

  # Admin public keys (so admins can re-encrypt secrets locally).
  # Add age keys for each admin who needs to manage secrets.
  superq = "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  mcint  = "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

  allKeys = [ hostKey superq mcint ];
in
{
  "mysql-root.age".publicKeys = allKeys;
  "mysql-mediawiki.age".publicKeys = allKeys;
  "mysql-pydonate.age".publicKeys = allKeys;
  "stripe-keys.age".publicKeys = allKeys;
  "prometheus-auth.age".publicKeys = allKeys;
  "grafana-admin.age".publicKeys = allKeys;
}
