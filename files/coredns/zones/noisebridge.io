; vim: ts=8 et
;zone for noisebridge.io

$TTL 3600

noisebridge.io.        IN      SOA     ns.noisebridge.net. hostmaster.noisebridge.io.  (
        2020033100 ; Serial
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

; aliases
www     300     IN      CNAME   m3.noisebridge.net.
