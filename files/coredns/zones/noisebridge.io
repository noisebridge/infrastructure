; vim: ts=8 et
;zone for noisebridge.io

$TTL 3600

noisebridge.io.        IN      SOA     ns.noisebridge.net. hostmaster.noisebridge.io.  (
        2026073100 ; Serial
        3600 ; Refresh
        300 ; Retry
        604800 ; Expire
        300 ) ; Minimum

; name server records
@               IN      NS      ns1.noisebridge.net.
@               IN      NS      ns2.noisebridge.net.

; hostnameless access
@       300     IN      A       216.252.162.220
@       300     IN      AAAA    2602:ff06:725:5:dc::1337

; SPF
@       86400   IN      TXT     "v=spf1 redirect=spf.noisebridge.net"

; subdomains
barnyard        86400   IN      NS      brony.noisebridge.io.

; aliases
blog            10800   IN      CNAME   blogs.vip.gandi.net.
brony           1800    IN      A       199.241.139.224
cia             1800    IN      A       199.188.195.8
cycletrailer    1800    IN      CNAME   cycletrailer.noisebridge.net.
jitsi           1800    IN      A       199.188.195.96
pegasus         1800    IN      CNAME   pegasus.noisebridge.net.
share           1800    IN      A       199.188.195.78
webmail         10800   IN      CNAME   webmail.gandi.net.
www             10800   IN      CNAME   m3.noisebridge.net.
zeppelin        1800    IN      CNAME   zeppelin.noisebridge.net.

; DNS-01 challenges enable automatic provisioning of certificates for services
; whose names have no publically accessible HTTP-01 route, and are the ONLY way
; to get a wildcard certificate.
;
; More info:
; * https://www.noisebridge.net/wiki/NoiseGarden
; * https://cert-manager.io/docs/configuration/acme/dns01/acme-dns/
; * https://github.com/joohoi/acme-dns/
;
; Unlike noisebridge.net, this zone does NOT use the public auth.acme-dns.io.
; It delegates to a self-hosted acme-dns on the NoiseGarden root cluster --
; the "we can also self-host this service" note in noisebridge.net, done. The
; delegation is a real subzone, so acme-dns is authoritative for
; acme.noisebridge.io and answers the challenge lookups directly.
;
; acme-dns is authoritative for acme.noisebridge.io. Its NS host lives here in
; the parent zone rather than inside the delegated subzone, so no glue record
; is needed. Both records point at the root cluster's public IP; that address
; is also written into the acme-dns config, so the two must be changed
; together (infra/clusters/root/infra/acme-dns/ in the noisegarden repo).
acme                        IN      NS      acme-dns.noisebridge.io.
acme-dns                    IN      A       204.168.192.161

; The wildcard delegation. cert-manager writes its challenge token to the
; subdomain below over acme-dns's in-cluster HTTP API; Let's Encrypt follows
; this CNAME to find it. One record covers every name in the zone -- apex,
; subdomains and *.noisebridge.io alike -- so adding a hostname later needs no
; zone change here.
;
; The subdomain is minted by the acme-dns server at registration and exists
; ONLY in that server's database. It cannot be regenerated to match: if that
; database is lost this CNAME dangles and every renewal for the zone fails
; until someone re-registers and edits this line.
;
; To register a further zone against the same server, POST to /register from
; inside the cluster (it has no public endpoint by design) -- see
; infra/clusters/root/infra/acme-dns/README.md in the noisegarden repo.
_acme-challenge             IN      CNAME   03171cac-3a64-4105-a1a6-eacf70b4a076.acme.noisebridge.io.
