Role Name
=========

This role encompasses the safespace application now hosted in docker behind a caddy reverse proxy (same architecture as before)
The main change is that caddy and php are now containerized via docker compose and won't cry if we change either system binary on the deployed hardware node.

Requirements
------------

NA

Role Variables
--------------

This application depends on `safespace_public_discord_channel_webhook_token` and `safespace_private_discord_channel_webhook_token` which are currently defined in `group_vars/m6_noisebridge_net/safespace_secrets.yml`.

Dependencies
------------


License
-------

BSD

Author Information
------------------

Bjorn