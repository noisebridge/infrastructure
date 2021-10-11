; vim: ts=8 et
;zone for noisebridge.io

$TTL 3600

noisebridge.io.        IN      SOA     ns.noisebridge.net. hostmaster.noisebridge.io.  (
        2020122000 ; Serial
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
blog            10800   IN      CNAME   blogs.vip.gandi.net.
cia             1800    IN      A       199.188.195.8
cycletrailer    1800    IN      CNAME   cycletrailer.noisebridge.net.
jitsi           1800    IN      A       199.188.195.96
pegasus         1800    IN      A       pegasus.noisebridge.net.
share           1800    IN      A       199.188.195.78
webmail         10800   IN      CNAME   webmail.gandi.net.
www             10800   IN      CNAME   m3.noisebridge.net.
zeppelin        1800    IN      A       zeppelin.noisebridge.net.
