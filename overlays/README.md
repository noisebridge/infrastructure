# overlays/

Nix package overlays for customizing upstream packages.

## caddy.nix

Builds a custom Caddy binary with the [caddy-ratelimit](https://github.com/mholt/caddy-ratelimit) plugin using `xcaddy`. This is used by `modules/caddy.nix` to provide rate limiting on donation endpoints.

The custom package is available as `pkgs.caddy-custom` after the overlay is applied.
