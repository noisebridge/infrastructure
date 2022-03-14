# Noisebridge Infrastructure

This repo contains configuration and code to deploy Noisebridge infrastrucutre.

## Code of Conduct

Noisebridge infrastructure members follow the Rack Code of Conduct

### Security

Noisebridge infrastructure members protect the privacy and security of our systems and members.

* Secrets should be checked in using ansible-vault.
* The vault password should be kept safe.
* Care needs to be taken when handling Issues and PRs to protect the privacy of members.

### Reliability

Noisebridge infrastructure members keep services up and running.

* Test changes as best as you can before pushing to production.
* Improve monitoring as you go.
* Think first, deploy once.
* Rollback quickly when things fail.

### Reproducibility

Noisebridge infrastructure members ensure that changes are made in a way that is reproducibile.

* All changes to infrastructure should be checked into this repo.
* Changes should be made with Pull Requests so that they can be reviewed.
* Think about making sure your changes are reasonably future-proof.

## Ansible

Much of the code here is the Noisebridge infrastucture [Ansible](https://docs.ansible.com/ansible/latest/) configuration. Ansible is used to automatically deploy configuration to the various nodes (VMs and hardware in the space).

### Submodules

This repo includes git submodules to vendor external source.  You need to update them with this helper command.

    ./update-submodules.sh

### Deployment

Deploying the entire thing should be possible with just one command:

    ansible-playbook site.yml

Usually, you will want to limit your deployment to specific host groups:

    ansible-playbook site.yml --limit noisebridge_net
    
You can be even more specific, for example, this deploys only to the noisebridge\_net roles tagged `website`:

    ansible-playbook site.yml --limit noisebridge_net -t website

### Ansible Vault

Some data is encrypted so that secrets (ie people's email addresses) aren't public. To edit files with secrets, first put the ansible vault password in a `.vault-password` file in the root directory of the git repo, then run:

    ansible-vault edit path/to/secrets.yml

To get the vault password, check https://www.noisebridge.net/wiki/Accounts to see who has it.

### Remote access to .noise

In order to deploy to machines remotely, you will need to configure a bastion bouncer.

In your `~/.ssh/config` add the folowing.

    Host *.noise
      User         YOU
      ProxyCommand ssh pegasus.noisebridge.net -W %h:%p

## Joining

See https://discuss.noisebridge.info/c/guilds/rack for guidance, specifically the sticky.
