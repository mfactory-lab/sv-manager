# Solana Validators Manager

automatically bootstrap solana validator node inclusive performance optimizations and monitoring

- [Preface](#Preface)
- [Node requirements](#node-requirements)
- [What does it do with your Validator Node exactly](#what-does-it-do-with-your-validator-node-exactly)
  - [Configure Ubuntu](#configure-ubuntu)
  - [Bootstrap Solana cli](#bootstrap-solana-cli)
  - [Configure node monitoring](#configure-node-monitoring)
- [How to install Ansible](#how-to-install-ansible)
  - [on MacOS](#on-macos)
  - [on Ubuntu](#on-ubuntu)
  - [on Windows](#on-windows)
- [How to configure Solana Validator Manager](#how-to-configure-solana-validator-manager)
- [How to use](#how-to-use)
  - [from local machine](#from-local-machine)
  - [directly from Validator Node](#from-validator-node)
  - [via docker](#via-docker)
- [Which functions are supported](#which-functions-are-supported)
  - [install](#install-validator-node)
  - [update Solana Version](#update-solana-version)
  - [install or update monitoring](#install-or-update-monitoring)
    - [how to install monitoring with ansible](#how-to-install-monitoring-with-ansible)
    - [how to install monitoring manually](#how-to-install-monitoring-manually)
  - [migrate your current setup to supported by sv-manager](#migrate-your-current-setup-to-supported-by-sv-manager)
    - [how to migrate your setup semi automatically](#how-to-migrate-your-setup-semi-automatically)
    - [how to migrate your setup manually](#how-to-migrate-your-setup-manually)
  [Useful links](#useful-links)
- [How can you support this project](#how-can-you-support-this-project)


## Preface

* [History](./history.md)
* [Roadmap](./roadmap.md)

[Solana](https://solana.com/) is a fast, secure, and censorship resistant blockchain providing 
the open infrastructure required for global adoption.

For running of solana blockchain it needs to decentralize the network by providing computing resources 
to validate transactions or storage for ledger redundancy.

The computer resources are provided by validators who needs to maintain high performance linux nodes.

There are now two Solana clusters, [Mainnet-Beta](https://explorer.solana.com/) 
and [Testnet](https://explorer.solana.com/?cluster=testnet)

Mainnet-Beta-Cluster is maintained by about 700 validators and Testnet-Cluster by about 1700 validators.

We guess that most of them bootstraps their nodes manually goes throw 
the [Solana Docs](https://docs.solana.com/running-validator) or similar community guidelines.

That's why we are wondering if there are two equal setups of solana validator.

This causes that is almost impossible to support validators with node issues and help them to improve node 
and as a result of it cluster performance.

We want to provide a toolkit that helps validator to bootstrap and maintain their nodes in the similar way.

This ansible scripts is a compilation of best practices and community guidelines. 

Enjoy and improve it.


## Node requirements

* We have tested it only with Ubuntu 20.04, but every linux distro with apt and systemd should be supported.
* Support for other Linux-Distributives will be implemented soon.  
* Check Solana [Validator requirements](https://docs.solana.com/running-validator/validator-reqs)

## What does it do with your Validator Node exactly

### Configure Ubuntu

[Ubuntu role](./roles/configure_ubuntu)

that role configures your ubuntu node to be more performant and stable with validation

1. Create ansible user
2. Create solana user
3. Create swap file
4. Create ram disk for accounts db
5. Set cpu governor to performance
6. Configure firewall

### Bootstrap Solana cli

[Solana cli role](./roles/solana_cli)

that role installs or updates solana cli

### Configure node monitoring

- [monitoring](roles/monitoring)

that role configures sending of validator and node metrics to our [grafana dashboard](https://solana.thevalidators.io)

## How to install Ansible

### On macOS

    brew update; brew install ansible

### On Ubuntu

    apt-get update; apt-get install ansible

### On Windows

unfortunately ansible is not directly supported on Windows, we are working on a docker image
which will directly provide a support for Solana Validator Manager, until that you can use
[ansible docker image](https://hub.docker.com/r/ansible/ansible) on your own.

## How to configure Solana Validator Manager

*!only testnet configuration is supported now!*

1. clone git repository
   git clone ...
1. copy or rename [inventories_example directory](inventory_example) to directory named *inventory*
2. add to your inventories/hosts.yaml

* validator name
* ip-address of your validator node

````yaml
all:
  children:
    local:
      vars:
        become: false
        ansible_connection: local
        ansible_python_interpreter: "{{ ansible_playbook_python }}"
      hosts:
        localhost
    remote:
      vars:
        ansible_user: root
      children:
        validator:
          vars:
            validator_name: <- HERE
#            keybase_username: ""
#            validator_homepage: ""
            upload_validator_keys: False <- Set it to True if you want to upload your keys
#            secrets_path: /home/solana/.secrets
#            set_validator_info: True
#            service_user: solana
#            ledger_path: /home/solana/ledger
#            lvm_enabled: False
#            lvm_vg: vg00
#            solana_validator_service: restarted <- Set it to stopped if you want to check your setup
#            swap_file_size_gb: 64
#            ramdisk_size_gb: 64
#            cluster_environment: testnet
#            cluster_rpc_address: https://testnet.solana.com
          hosts:
            0.0.0.0 <- HERE
````

in case you have already identity keys (the most of you will have at least a validator identity key)

4. copy your validator identity key, if any, into .secrets/{{YOUR VALIDATOR NAME}}/solana
5. copy your vote account identity key, if any, into .secrets/{{YOUR VALIDATOR NAME}}/solana
6. set upload_validator_keys to True

## How to use

### from local machine

1. make sure you have access to you validator node as a root user via [ssh-key](https://www.cyberciti.biz/faq/ubuntu-18-04-setup-ssh-public-key-authentication/)
2. configure hosts.yaml
3. start playbook

ansible-playbook install_validator.yaml -v

if you run an ubuntu server with more or less standard configuration than in few minutes
your validator node should be up, and you can observe your metrics on [our metrics dashboard](https://solana.thevalidators.io)

### from Validator Node

coming soon!

## Which functions are supported

### Install Validator Node

ansible-playbook pb_install_validator.yaml -v

### Update Solana Version

* bump solana version in group_vars/all.yaml

```yaml
...
validator:
  version: v1.6.7 <- set new version here
...
```

* start ansible playbook

  ansible-playbook pb_update_validator.yaml  -v

### Install or update Monitoring

* if you just want to use monitoring
* or want update monitoring library

#### How to install monitoring with ansible

  ansible-playbook pb_install_monitoring.yaml  -v

#### How to install monitoring manually

coming soon

### Migrate your current setup to supported by sv-manager

#### How to migrate your setup semi-automatically

coming soon

#### How to migrate your setup manually

coming soon

## Useful links

* [Solana](https://solana.com/)
* [Validator documentation](https://docs.solana.com/running-validator)
* [Ansible documentation](https://docs.ansible.com/)
* [Monitoring Dashboard](https://solana.thevalidators.io/)
* [Joogh Validator](https://joogh.io)

## How can you support this project

- Join the community on telegramm [t.me/thevalidators](https://t.me/thevalidators)
- Fork, improve, PR
- Donate Sol to  [Joogh Validator Identity Account](https://joogh.io) Solana: 8yjHdsCgx3bp2zEwGiWSMgwpFaCSzfYAHT1vk7KJBqhN
- Donate BTC: bc1q9vkmfpmk77j2kcsdy2slnv6ld4ahg2g5guysvy
- Stake on [Joogh Validator](https://solanabeach.io/validator/DPmsofVJ1UMRZADgwYAHotJnazMwohHzRHSoomL6Qcao)

### [Powered by mFactory Team](https://mfactory.tech)

[1]: (https://solana.com/)
[2]: (https://docs.solana.com/running-validator)
[3]: (https://docs.ansible.com/)
[4]: (https://solana.thevalidators.io/)
[5]: (https://mfactory.ch)
[6]: (https://joogh.io)
[7]: (https://solana.thevalidators.io)

