# ansible

the noisebridge infrastucture playbooks

## Submodules

This repo includes git submodules to vendor external source.  You need to update them with this helper command.

    ./update-submodules.sh

## Deployment

Deploying the entire thing should be possible with just one command:

    ansible-playbook site.yml

Usually, you will want to limit your deployment to specific host groups:

    ansible-playbook site.yml --limit noisebridge-net


## HERE BE DRAGONS

This is an aspirational repository for use to provision future noisebridge
infrastructure and deprecate our old and tired VMs. It is not currently used
for production services - don't rely on it as a source of truth for anything.
