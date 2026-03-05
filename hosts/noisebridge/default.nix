# Host configuration for the Noisebridge colo server.
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";
  networking.hostId = "deadbeef"; # Required by ZFS — replace with: head -c 8 /etc/machine-id

  # Hostname
  networking.hostName = "noisebridge";
  networking.domain = "noisebridge.net";

  # Static networking — replace IPs with actual colo assignments
  networking.useDHCP = false;
  networking.interfaces.eno1 = {
    ipv4.addresses = [{
      address = "192.0.2.1";      # TODO: replace with colo IPv4
      prefixLength = 24;
    }];
    ipv6.addresses = [{
      address = "2001:db8::1";    # TODO: replace with colo IPv6
      prefixLength = 64;
    }];
  };
  networking.defaultGateway = {
    address = "192.0.2.254";       # TODO: replace with colo gateway
    interface = "eno1";
  };
  networking.defaultGateway6 = {
    address = "2001:db8::fffe";    # TODO: replace with colo gateway
    interface = "eno1";
  };
  networking.nameservers = [ "127.0.0.1" "::1" ];

  # Timezone
  time.timeZone = "US/Pacific";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # NTP
  services.timesyncd.enable = true;

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tmux
    curl
    wget
    jq
    dig
    tcpdump
    zfs
  ];

  # ZFS scrub
  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  system.stateVersion = "24.11";
}
