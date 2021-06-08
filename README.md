# Solana Validator Manager

### Automatically bootstrap a Solana validator node, optimize its performance, and connect the node to a monitoring dashboard

[Solana](https://solana.com/) is a fast, secure, and censorship-resistant blockchain providing open infrastructure necessary for global adoption.

In order to run, the Solana blockchain requires a decentralized network comprising computing resources to validate transactions as well as storage for ledger redundancy.

The computer resources are provided by validators who need to maintain high-performance Linux nodes.

There are now two Solana clusters, [Mainnet-Beta](https://explorer.solana.com/)  and [Testnet](https://explorer.solana.com/?cluster=testnet).

The Mainnet-Beta cluster is maintained by ~700 validators, and the Testnet cluster by ~1700 more validators.

Most of the people running these just bootstrap their nodes manually, referring to the Solana docs or similar community guides. Apparently, there are no 2 identical setups across these 2400 validators.

As a result, it is virtually impossible to support validators having issues with their nodes and/or help them improve their node, thus contributing to the overall cluster performance.

What we would like to do is provide a toolkit to help validators bootstrap and maintain their nodes in a uniform, consistent way.

The Ansible scripts we have created for this purpose are a compilation of best practices and community guidelines.

Please use them, enjoy them, and improve them.

### Quick Install

* Log in to your server
* __If you don’t have a key pair yet, skip this step: it will be generated automatically__.

  If you have a key pair, create the key pair file in your home directory (you can also upload it via scp if you prefer):
  ````shell
  nano ~/validator-keypair.json
  ````   
  Paste your key pair, save the file (ctrl-O) and exit (ctrl-X).
* __If you don’t have a *vote account* key pair yet, skip this step: it will be generated automatically__.

  If you have a *vote account* key pair, create the key pair file in your home directory (or upload it via scp):
  ````shell
   nano ~/vote-account-keypair.json
  ````  
  Paste your key pair, save the file (ctrl-O) and exit (ctrl-X).
* Run this command…

````shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mfactory-lab/sv-manager/latest/install/install_validator.sh)"
````
  <img src="docs/launch.gif" width=500>
…and follow the wizard’s instructions (__enter your own Node name!__):

  <img src="docs/wizard.gif" width=500>

That's it, you are all set!

### How to update validator

````shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mfactory-lab/sv-manager/latest/install/update_validator_version.sh)" --version 1.7.0
````

### how to update monitoring

````shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mfactory-lab/sv-manager/latest/install/update_monitoring.sh)" 
````


### If you want more control over the configuration of your node, please refer to the [advanced technical specifications](docs/advanced.md)

## We fixed a bug that sometimes caused the sv-manager to fail to copy the keypair file.
If you launched sv-manager on May 16, between 0:00 and 12:00 UTC and
you have only about *1 SOL* on your identity account,

then please run our quick fix:

`````shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mfactory-lab/sv-manager/latest/install/quick_fix_wrong_keys.sh)"
`````

It will backup your keypair, copy your correct keypair to /home/solana/secrets, set up your vote account, create a vote account keypair, and link your Identity keypair to your Vote account keypair. It will then restart the validator node.


## Useful links

* [Solana](https://solana.com/)
* [Monitoring Dashboard](https://solana.thevalidators.io/)
* [Validator docs](https://docs.solana.com/running-validator)

## How you can support this project

- Join our Telegram community [t.me/thevalidators](https://t.me/thevalidators)
- Fork, improve, and promote
- Stake with [Joogh Validator](https://solanabeach.io/validator/DPmsofVJ1UMRZADgwYAHotJnazMwohHzRHSoomL6Qcao)
- Donate Sol to [Joogh Validator Identity Account](https://joogh.io) on Solana: 8yjHdsCgx3bp2zEwGiWSMgwpFaCSzfYAHT1vk7KJBqhN
- Donate BTC: bc1q9vkmfpmk77j2kcsdy2slnv6ld4ahg2g5guysvy

### [Powered by mFactory Team](https://mfactory.tech)
