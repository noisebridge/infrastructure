{
  description = "Noisebridge Infrastructure — NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, disko, deploy-rs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      overlays.default = import ./overlays/caddy.nix;

      nixosConfigurations.noisebridge = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit agenix; };
        modules = [
          # Apply the custom Caddy overlay
          { nixpkgs.overlays = [ self.overlays.default ]; }
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./hosts/noisebridge
          ./modules/security.nix
          ./modules/users.nix
          ./modules/coredns.nix
          ./modules/mysql.nix
          ./modules/mediawiki.nix
          ./modules/caddy.nix
          ./modules/prometheus.nix
          ./modules/grafana.nix
          ./modules/pydonate.nix
          ./modules/backup.nix
        ];
      };

      deploy.nodes.noisebridge = {
        hostname = "noisebridge.net";
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = deploy-rs.lib.${system}.activate.nixos
            self.nixosConfigurations.noisebridge;
        };
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        deploy-rs.lib;
    };
}
