# Grafana dashboards.
# Configuration from group_vars/space_noisebridge_net/grafana.yml.
{ config, pkgs, lib, ... }:
{
  age.secrets = {
    grafana-admin = {
      file = ../secrets/grafana-admin.age;
      owner = "grafana";
    };
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "https://grafana.noisebridge.net";
        domain = "grafana.noisebridge.net";
      };

      security = {
        admin_user = "admin";
        admin_password = "$__file{${config.age.secrets.grafana-admin.path}}";
      };

      "auth.anonymous" = {
        enabled = true;
        org_name = "Noisebridge";
        org_role = "Viewer";
      };

      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
          editable = false;
        }
      ];
    };
  };
}
