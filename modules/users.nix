# Admin user accounts.
# SSH keys fetched from GitHub via builtins.fetchurl (requires --impure or
# a fetched-keys directory). To avoid impure eval, pin keys in this file.
{ config, pkgs, lib, ... }:
let
  # Admins from the original group_vars/all/default.yml.
  # GitHub keys are fetched at eval time. For pure flake evaluation,
  # replace with pinned keys: openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
  mkGitHubUser = { name, github, description, extraKeys ? [] }: {
    inherit name;
    value = {
      isNormalUser = true;
      inherit description;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = extraKeys;
      # Fetch keys from GitHub at build time (add to extraKeys after fetching):
      #   curl -sL https://github.com/${github}.keys
      openssh.authorizedKeys.keyFiles =
        if github != null then [
          (builtins.fetchurl {
            url = "https://github.com/${github}.keys";
            # sha256 will be filled on first eval; nix will tell you the hash
          })
        ] else [];
    };
  };
in
{
  users.mutableUsers = false;

  users.users = builtins.listToAttrs (map mkGitHubUser [
    {
      name = "superq";
      github = "SuperQ";
      description = "Ben Kochie";
    }
    {
      name = "rizend";
      github = null;
      description = "rizend";
      extraKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWvlc3+qDxhKE3jCCxKKU1h9QJyhCqLgHAwkiokvSPig6dXZW9f8uS/1CNMEmB5avrZhT6S3V00NExqZMldJechROhQoZb6YrUzakaeJCHrbThotQ/TlDuRWCCEh+y/qowk261X4Rbdx/KMwPuROP0p+pw2u3CVoLC7ejnsCwzTMZJ450QtZau0nvP7PY1vnehg2npA4HOqtwjOABJlMMpSZfaQdddwQJ7YE01GLpXF73Lwcnyue51fWFdjsQwIeQM2feO0yf1r1fjoLyMfWCVLK2GI0ONXVFWKQ52kfzr4QQ7Tq+Xi12qr7KGlHZ8yl7tw3MUoyU7k0HrUea1F8WF"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvHlZKV8yBsJOkeu2FkWZ1UDY/uTS8bBUbqh1W0pJ3BMec55uvRLNv1AT5Z7RHKbwdjiZTBm6sP0CRVjsOxeGRCVeddHx1SxsXeihZIRQLHX+Z7M1YwYdzmzRDIEhuZhp+RnGH71ESVEHlmUhNPYsNmlgE3nyNbbDatYRZQqC204pal6cz4CHRUWYIozAQvpO8BF+cNDbNgT1yR5DWflwHErlv8yltmxNjh+gQQgp7RzI+05uzpRgumLCIqdHIKUflDJGvZXnUNAr5nv8Xe3W77AZz348nK2SYoD7dOBw23LpEzmy0mENL+/d3ZCuricslc1eBqCpVxJiF7s/RCtix"
      ];
    }
    {
      name = "bfb";
      github = "kevinjos";
      description = "bfb";
    }
    {
      name = "jof";
      github = "jof";
      description = "Jonathan Lassoff";
    }
    {
      name = "mcint";
      github = "mcint";
      description = "Loren McIntyre";
    }
  ]);

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;
}
