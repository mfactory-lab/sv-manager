[Change History](history.md)

# Solana Validators Manager

- [Overview](#overview)
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
- [Which functions are supported](#which-functions-are-supported)
  - [install](#install-validator-node)
  - [update Solana Version](#update-solana-version)
  - [install or update monitoring](#install-or-update-monitoring)
- [Useful links](#useful-links)
- [How can you support this project](#how-can-you-support-this-project)


## Overview

* [History](./history.md)
* [Roadmap](./roadmap.md)

## Node requirements

* Only Ubuntu 20.04 is supported
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
1. copy or rename [inventories_example directory](inventory_example) to directory named *inventories*
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
#            upload_validator_keys: False
#            secrets_path: /home/solana/.secrets
#            set_validator_info: True
#            service_user: solana
#            ledger_path: /home/solana/ledger
#            lvm_enabled: False
#            lvm_vg: vg00
#            solana_validator_service: restarted
#            swap_file_size_gb: 64
#            ramdisk_size_gb: 64
#            cluster_environment: testnet
#            cluster_rpc_address: https://testnet.solana.com
          hosts:
            0.0.0.0 <- HERE
````

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

  ansible-playbook pb_install_monitoring.yaml  -v

## Useful links

* [Solana](https://solana.com/)
* [Validator documentation](https://docs.solana.com/running-validator)
* [Ansible documentation](https://docs.ansible.com/)
* [Monitoring Dashboard](https://solana.thevalidators.io/)
* [Joogh Validator](https://joogh.io)
* [Powered by mFactory GmbH](https://mfactory.ch)

## How can you support this project

- Join the community on telegramm [t.me/thevalidators](https://t.me/thevalidators)
- Fork, improve, PR
- Donate Sol to  [Joogh Validator Identity Account](https://joogh.io) Solana: 8yjHdsCgx3bp2zEwGiWSMgwpFaCSzfYAHT1vk7KJBqhN
- Donate BTC: bc1q9vkmfpmk77j2kcsdy2slnv6ld4ahg2g5guysvy
- Stake on [Joogh Validator](https://solanabeach.io/validator/DPmsofVJ1UMRZADgwYAHotJnazMwohHzRHSoomL6Qcao)

### [Powered by mFactory Team](https://mfactory.ch)

[1]: (https://solana.com/)
[2]: (https://docs.solana.com/running-validator)
[3]: (https://docs.ansible.com/)
[4]: (https://solana.thevalidators.io/)
[5]: (https://mfactory.ch)
[6]: (https://joogh.io)
[7]: (https://solana.thevalidators.io)

