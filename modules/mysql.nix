# MariaDB database server.
# Databases: noisebridge_mediawiki (wiki), donate_prod (pydonate)
# Tuning carried over from Ansible group_vars.
# MyDumper logical backups via systemd timer.
{ config, pkgs, lib, ... }:
{
  age.secrets = {
    mysql-root = {
      file = ../secrets/mysql-root.age;
      owner = "mysql";
    };
    mysql-mediawiki = {
      file = ../secrets/mysql-mediawiki.age;
      owner = "mysql";
    };
    mysql-pydonate = {
      file = ../secrets/mysql-pydonate.age;
      owner = "mysql";
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/var/lib/mysql";

    settings = {
      mysqld = {
        bind-address = "127.0.0.1";

        # InnoDB tuning (from Ansible mysql.yml)
        innodb_buffer_pool_size = "128M";
        innodb_log_file_size = "64M";
        innodb_flush_method = "O_DIRECT";
        innodb_file_per_table = 1;

        # Disable query cache (useless for InnoDB, from Ansible config)
        query_cache_type = 0;
        query_cache_size = 0;
        query_cache_limit = 0;

        # Character set
        character-set-server = "utf8mb4";
        collation-server = "utf8mb4_unicode_ci";
      };
    };

    ensureDatabases = [
      "noisebridge_mediawiki"
      "donate_prod"
      "donate_test"
    ];

    ensureUsers = [
      {
        name = "wiki";
        ensurePermissions = {
          "noisebridge_mediawiki.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = "donate";
        ensurePermissions = {
          "donate_prod.*" = "ALL PRIVILEGES";
          "donate_test.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # MyDumper for logical backups
  environment.systemPackages = [ pkgs.mydumper ];

  systemd.services.mydumper-backup = {
    description = "MyDumper MySQL logical backup";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = toString [
        "${pkgs.mydumper}/bin/mydumper"
        "--host" "localhost"
        "--user" "root"
        "--outputdir" "/var/backups/mysql/latest"
        "--compress"
        "--threads" "4"
        "--rows" "100000"
        "--build-empty-files"
      ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/backups/mysql/latest";
      ExecStartPost = pkgs.writeShellScript "mydumper-rotate" ''
        set -euo pipefail
        BACKUP_ROOT=/var/backups/mysql
        DATE=$(date +%Y-%m-%d_%H%M)
        mv "$BACKUP_ROOT/latest" "$BACKUP_ROOT/$DATE"
        mkdir -p "$BACKUP_ROOT/latest"
        # Remove backups older than 28 days
        find "$BACKUP_ROOT" -maxdepth 1 -mindepth 1 -type d -mtime +28 -exec rm -rf {} +
      '';
      User = "mysql";
      Group = "mysql";
    };
  };

  systemd.timers.mydumper-backup = {
    description = "Daily MyDumper backup timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
