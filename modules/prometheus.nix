# Prometheus monitoring with node exporter and blackbox exporter.
# Scrape configs translated from group_vars/noisebridge_net/prometheus.yml.
{ config, pkgs, lib, ... }:
{
  age.secrets = {
    prometheus-auth = {
      file = ../secrets/prometheus-auth.age;
      owner = "prometheus";
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    stateDir = "prometheus2";

    retentionTime = "90d";
    extraFlags = [
      "--storage.tsdb.retention.size=5GB"
      "--query.max-samples=10000000"
    ];

    globalConfig = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
      evaluation_interval = "30s";
    };

    scrapeConfigs = [
      # Prometheus self-monitoring
      {
        job_name = "prometheus";
        static_configs = [{
          targets = [ "localhost:9090" ];
        }];
      }

      # Node exporter (local machine metrics)
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:9100" ];
        }];
      }

      # CoreDNS metrics
      {
        job_name = "coredns";
        static_configs = [{
          targets = [ "localhost:9153" ];
        }];
      }

      # Caddy metrics (via localhost metrics endpoint)
      {
        job_name = "caddy";
        static_configs = [{
          targets = [ "localhost:2019" ];
        }];
      }

      # Grafana metrics
      {
        job_name = "grafana";
        static_configs = [{
          targets = [ "localhost:3000" ];
        }];
      }

      # Blackbox HTTP probes — IPv4
      {
        job_name = "blackbox_http_v4";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx_v4" ];
        };
        static_configs = [{
          targets = [
            "http://noisebridge.net"
            "https://noisebridge.net"
            "https://donate.noisebridge.net"
            "https://www.noisebridge.net"
          ];
        }];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:9115";
          }
        ];
      }

      # Blackbox HTTP probes — IPv6
      {
        job_name = "blackbox_http_v6";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx_v6" ];
        };
        static_configs = [{
          targets = [
            "http://noisebridge.net"
            "https://noisebridge.net"
            "https://donate.noisebridge.net"
            "https://www.noisebridge.net"
          ];
        }];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:9115";
          }
        ];
      }
    ];

    # Node exporter
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9100;
      enabledCollectors = [
        "systemd"
        "zfs"
      ];
    };

    # Blackbox exporter
    exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9115;
      configFile = pkgs.writeText "blackbox.yml" (builtins.toJSON {
        modules = {
          http_2xx_v4 = {
            prober = "http";
            http = {
              preferred_ip_protocol = "ip4";
              ip_protocol_fallback = false;
            };
          };
          http_2xx_v6 = {
            prober = "http";
            http = {
              preferred_ip_protocol = "ip6";
              ip_protocol_fallback = false;
            };
          };
        };
      });
    };
  };
}
