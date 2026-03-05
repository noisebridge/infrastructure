# ZFS snapshot management with Sanoid + optional off-site replication with Syncoid.
{ config, pkgs, lib, ... }:
{
  # Sanoid — automated ZFS snapshot lifecycle management
  services.sanoid = {
    enable = true;

    datasets = {
      "tank/mysql" = {
        autosnap = true;
        autoprune = true;
        hourly = 24;
        daily = 30;
        monthly = 6;
      };
      "tank/mediawiki" = {
        autosnap = true;
        autoprune = true;
        hourly = 24;
        daily = 30;
        monthly = 6;
      };
      "tank/prometheus" = {
        autosnap = true;
        autoprune = true;
        daily = 14;
      };
      "tank/grafana" = {
        autosnap = true;
        autoprune = true;
        daily = 14;
      };
      "tank/backups" = {
        autosnap = true;
        autoprune = true;
        daily = 30;
        monthly = 3;
      };
    };
  };

  # Syncoid — off-site ZFS replication (optional, enable when backup target is available)
  # Uncomment and set the target host/dataset when a backup destination is provisioned.
  #
  # services.syncoid = {
  #   enable = true;
  #   interval = "daily";
  #   commands = {
  #     "tank/mysql" = {
  #       target = "backup-user@backup-host:tank/offsite/mysql";
  #       sendOptions = "w"; # raw send (preserves encryption)
  #     };
  #     "tank/mediawiki" = {
  #       target = "backup-user@backup-host:tank/offsite/mediawiki";
  #       sendOptions = "w";
  #     };
  #     "tank/backups" = {
  #       target = "backup-user@backup-host:tank/offsite/backups";
  #       sendOptions = "w";
  #     };
  #   };
  # };

  environment.systemPackages = with pkgs; [
    sanoid  # includes syncoid
    lzop    # for compressed ZFS send
    mbuffer # for buffered ZFS send
  ];
}
