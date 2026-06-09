; vim: ts=8 et
;zone for noisebridge.io

$TTL 3600

noisebridge.io. IN SOA helium.ns.hetzner.de. hostmaster.noisebridge.io. (
        2026033000 ; Serial
        3600 ; Refresh
        300 ; Retry
        604800 ; Expire
        300 ) ; Minimum

; name server records
@               IN      NS      helium.ns.hetzner.de.
@               IN      NS      hydrogen.ns.hetzner.com.
@               IN      NS      oxygen.ns.hetzner.com.
;@               IN      NS      ns1.noisebridge.net.
;@               IN      NS      ns2.noisebridge.net.

; The following records have been manually copied to Hetzner while
; we figure out how to best programatically control CoreDNS.

; ; hostnameless access
;@       300     IN      A       216.252.162.220
;@       300     IN      AAAA    2602:ff06:725:5:dc::1337

; ; SPF
;@       86400   IN      TXT     "v=spf1 redirect=spf.noisebridge.net"

; Note: The majority of services below are currently offline but
; are kept for posterity.

; ; subdomains
;barnyard        86400   IN      NS      brony.noisebridge.io.

; ; aliases
;brony           1800    IN      A       199.241.139.224
;pegasus         1800    IN      CNAME   pegasus.noisebridge.net.
;webmail         10800   IN      CNAME   webmail.gandi.net.
;www             10800   IN      CNAME   m3.noisebridge.net.
