Role Name
=========

This role encompasses the safespace application now hosted in docker behind a caddy reverse proxy (same architecture as before)
The main change is that caddy and php are now containerized via docker compose and won't cry if we change either system binary on the deployed hardware node. For the time being this is to be deployed on an internally exposed node called `wildwest`, but that will change in the near future so we can get the application back online.

Requirements
------------

NA

Role Variables
--------------

This application depends on `safespace_public_discord_channel_webhook_token` and `safespace_private_discord_channel_webhook_token` which are currently defined in `group_vars/wildwest/safespace.yml`.

Dependencies
------------

This adds a new dependency on `community.docker`


License
-------

BSD

Author Information
------------------

Blame me, Bjorn for this atrocity.