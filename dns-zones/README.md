# dns-zones/

Authoritative DNS zone files served by CoreDNS. These are copied to `/var/lib/coredns/zones/` on the host at activation time.

| Zone file | Domain |
|-----------|--------|
| `noisebridge.net` | Primary domain. A/AAAA, NS, MX, CNAME, TXT (SPF/DKIM/DMARC), DNSSEC signed. |
| `noisebridge.com` | Redirects to noisebridge.net. |
| `noisebridge.io` | Subdomains for various services. |
| `noisebridge.org` | Redirects to noisebridge.net. |
| `noisetor.net` | Tor service domain. |

## Editing zones

1. Edit the zone file directly.
2. **Increment the serial number** in the SOA record (format: `YYYYMMDDNN`).
3. Commit, push, and rebuild. CoreDNS will pick up the new zone on service restart.

## DNSSEC

DNSSEC is enabled for `noisebridge.net`. The signing key files (`Knoisebridge.net.+013+33211.key` and `.private`) must be placed in `/var/lib/coredns/keys/` on the host. These are not stored in the repo.

## Zone transfers

Zones are configured for AXFR transfer to secondary DNS servers. The allowed secondaries are defined in `modules/coredns.nix`.
