; vim: ts=8
;zone for noisebridge.com

$TTL 3600

noisebridge.com.	IN	SOA	ns.noisebridge.net. hostmaster.noisebridge.com.  (
				2018030600 ; Serial
				3600 ; Refresh
				300 ; Retry
				604800 ; Expire
				300 ) ; Minimum

; name server records
@		IN	NS	ns.noisebridge.net.
@		IN	NS	dns.hexapodia.org.

; hostnameless access
@	300	IN	A	216.252.162.220
@	300	IN	AAAA	2602:ff06:725:5:dc::1337

; aliases
www	300	IN	CNAME	m3.noisebridge.net.
