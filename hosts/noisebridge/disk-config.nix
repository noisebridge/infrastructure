# Declarative disk layout for the Noisebridge colo server.
# Two NVMe drives in a ZFS mirror with dedicated datasets.
{ ... }:
{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };
      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };
    };

    zpool = {
      tank = {
        type = "zpool";
        mode = "mirror";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          normalization = "formD";
          mountpoint = "none";
        };
        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
              atime = "off";
            };
          };
          "mysql" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/mysql";
            options = {
              mountpoint = "legacy";
              recordsize = "16K";
              primarycache = "metadata";
              logbias = "throughput";
            };
          };
          "mediawiki" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/mediawiki";
            options.mountpoint = "legacy";
          };
          "prometheus" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/prometheus2";
            options = {
              mountpoint = "legacy";
              recordsize = "128K";
            };
          };
          "grafana" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/grafana";
            options.mountpoint = "legacy";
          };
          "backups" = {
            type = "zfs_fs";
            mountpoint = "/var/backups";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
