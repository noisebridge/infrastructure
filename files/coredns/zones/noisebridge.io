; vim: ts=8 et
;zone for noisebridge.io

$TTL 3600

noisebridge.io.        IN      SOA     ns.noisebridge.net. hostmaster.noisebridge.io.  (
        2026090500 ; Serial
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

; mx records
; Stalwart on noisegarden-root. The target must be mail.noisegarden.nexus and
; not an in-zone name: Stalwart's mounted cert carries that single SAN, so an
; in-zone name would break strict-TLS senders.
@       300     IN      MX      10 mail.noisegarden.nexus.

; SPF
@       300     IN      TXT     "v=spf1 mx -all"

; DMARC
_dmarc  300     IN      TXT     "v=DMARC1; p=none; rua=mailto:root@noisegarden.nexus;"

; DKIM
; Deliberately empty: this domain is an ALIAS of noisegarden.nexus in
; Stalwart and DKIM keys are per-Domain, so nothing ever signs with
; d=noisebridge.io. A borrowed key here would make the domain look
; DKIM-protected and invite a DMARC tightening that hard-fails real mail.

; subdomains
barnyard        86400   IN      NS      brony.noisebridge.io.

;; Primary hosting servers.
; hetzner VPS
noisegarden-root        IN      A       204.168.192.161

; Services hosted on noisegarden-root
auth            IN      CNAME   noisegarden-root
code            IN      CNAME   noisegarden-root
git             IN      CNAME   noisegarden-root
headscale       IN      CNAME   noisegarden-root
mail            IN      CNAME   noisegarden-root
vault           IN      CNAME   noisegarden-root
parts           IN      CNAME   noisegarden-root
zulip           IN      CNAME   noisegarden-root

; intent: test live deploy of https://github.com/noisebridge/noisebridge-wiki
; alpha: push whatever, whenever ; beta: focus on pre-deploy stability
wiki-alpha      IN      CNAME   noisegarden-root
wiki-beta       IN      CNAME   noisegarden-root

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
; with no publically accessible HTTP-01 route, and are the ONLY way to get a
; wildcard certificate.
;
; Challenges here are answered by a self-hosted acme-dns on the NoiseGarden root
; cluster. To register a new subdomain, POST to /register from inside that
; cluster -- it has no public endpoint by design -- then point a CNAME at the
; fulldomain it returns.
;
; More info:
; * https://www.noisebridge.net/wiki/NoiseGarden
; * https://cert-manager.io/docs/configuration/acme/dns01/acme-dns/
; * infra/clusters/root/infra/acme-dns/README.md in the noisegarden repo
;
; The delegated subzone. Its NS host is the noisegarden-root record above, so no
; glue is needed; that address is also in the acme-dns config and the two must
; change together.
acme                        IN      NS      noisegarden-root.noisebridge.io.

; One CNAME covers every name in the zone, wildcard included. The target
; subdomain exists only in the acme-dns database and cannot be regenerated -- if
; that is lost, renewals fail until someone re-registers and edits this line.
_acme-challenge             IN      CNAME   03171cac-3a64-4105-a1a6-eacf70b4a076.acme.noisebridge.io.
