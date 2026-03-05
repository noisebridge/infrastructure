# Caddy reverse proxy with automatic TLS.
# Consolidates m3 (wiki), m5 (donate), and monitoring vhosts onto a single server.
# Uses custom Caddy build with rate-limit plugin (see overlays/caddy.nix).
{ config, pkgs, lib, ... }:
{
  age.secrets = {
    prometheus-auth = {
      file = ../secrets/prometheus-auth.age;
      owner = "caddy";
    };
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy-custom;

    # Global config
    globalConfig = ''
      servers {
        metrics
      }
    '';

    # Redirect bare domains and alternates to www.noisebridge.net
    virtualHosts."noisebridge.com, www.noisebridge.com" = {
      extraConfig = ''
        redir https://www.noisebridge.net{uri} permanent
      '';
    };

    virtualHosts."noisebridge.io, www.noisebridge.io" = {
      extraConfig = ''
        redir https://www.noisebridge.net{uri} permanent
      '';
    };

    virtualHosts."noisebridge.net" = {
      extraConfig = ''
        redir https://www.noisebridge.net{uri} permanent
      '';
    };

    virtualHosts."noisebridge.org, www.noisebridge.org" = {
      extraConfig = ''
        redir https://www.noisebridge.net{uri} permanent
      '';
    };

    # MediaWiki — www.noisebridge.net
    virtualHosts."www.noisebridge.net" = {
      extraConfig = ''
        # Block ClaudeBot
        @claudebot {
          header User-Agent *ClaudeBot*
        }
        respond @claudebot 403

        # Serve uploaded images
        route /images* {
          uri strip_prefix /images
          @svg path *.svg *.SVG
          header @svg Content-Security-Policy "default-src 'none'; style-src 'unsafe-inline'"
          header @svg Content-Disposition "attachment"
          file_server {
            root /var/lib/mediawiki/images
          }
        }

        # Static images (logo, favicon, etc.)
        route /img* {
          file_server {
            root /var/lib/mediawiki/img
          }
        }

        @favicon path /favicon.ico
        handle @favicon {
          file_server {
            root /var/lib/mediawiki/img
          }
        }

        # PHP-FPM
        php_fastcgi unix//run/phpfpm/mediawiki.sock

        file_server {
          hide *.php
        }

        # URL rewriting for MediaWiki short URLs
        rewrite / /index.php?title={path}
        redir / /wiki
      '';
    };

    # Donation app — donate.noisebridge.net
    virtualHosts."donate.noisebridge.net" = {
      extraConfig = ''
        # Rate limit donation endpoints
        rate_limit {
          zone donate_zone {
            key {remote_host}
            events 10
            window 1m
          }
        }
        reverse_proxy localhost:8888
      '';
    };

    # Prometheus — prometheus.noisebridge.net (basic auth protected)
    virtualHosts."prometheus.noisebridge.net" = {
      extraConfig = ''
        basic_auth {
          prometheus {file.${config.age.secrets.prometheus-auth.path}}
        }
        reverse_proxy localhost:9090
      '';
    };

    # Grafana — grafana.noisebridge.net
    virtualHosts."grafana.noisebridge.net" = {
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };

    # Metrics endpoint — hostname-based (for Prometheus scraping)
    virtualHosts."noisebridge.noisebridge.net" = {
      extraConfig = ''
        route /metrics {
          basic_auth {
            prometheus {file.${config.age.secrets.prometheus-auth.path}}
          }
          metrics
        }
        route /coredns/* {
          basic_auth {
            prometheus {file.${config.age.secrets.prometheus-auth.path}}
          }
          uri strip_prefix /coredns
          reverse_proxy localhost:9153
        }
        respond "Noisebridge Infrastructure"
      '';
    };
  };
}
