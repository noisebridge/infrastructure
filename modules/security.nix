# Firewall, SSH hardening, and fail2ban.
{ config, pkgs, ... }:
{
  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22   # SSH
      53   # DNS
      80   # HTTP (Caddy ACME + redirect)
      443  # HTTPS
    ];
    allowedUDPPorts = [
      53   # DNS
    ];
    logReversePathDrops = true;
  };

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = false;
      MaxAuthTries = 3;
    };
    openFirewall = true;
  };

  # Fail2ban
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
  };

  # Kernel hardening
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
  };

  # Automatic security updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false; # manual reboot only for a server
    dates = "04:00";
    flake = "github:noisebridge/infrastructure?dir=nixos";
  };
}
