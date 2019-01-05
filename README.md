# Noisebridge Infrastructure

This repo contains configuration and code to deploy Noisebridge infrastrucutre.

## Ansible

Much of the code here is the Noisebridge infrastucture [Ansible](https://docs.ansible.com/ansible/latest/) configuration. Ansible is used to automatically deploy configuration to the various nodes (VMs and hardware in the space).

### Submodules

This repo includes git submodules to vendor external source.  You need to update them with this helper command.

    ./update-submodules.sh

### Deployment

Deploying the entire thing should be possible with just one command:

    ansible-playbook site.yml

Usually, you will want to limit your deployment to specific host groups:

    ansible-playbook site.yml --limit noisebridge-net

### Remote access to .noise

In order to deploy to machines remotely, you will need to configure a bastion bouncer.

In your `~/.ssh/config` add the folowing.

    Host *.noise
      User         YOU
      ProxyCommand ssh pegasus.noisebridge.net -W %h:%p

