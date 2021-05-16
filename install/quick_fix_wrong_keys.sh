#!/bin/bash
#set -x -e
set -e

echo "###################### WARNING!!! ###################################"
echo "###   This script will perform the following operations:          ###"
echo "###   * backup your keypairs                                      ###"
echo "###   * copy your correct keypair to /home/solana/secrets         ###"
echo "###   * set up your vote account                                  ###"
echo "###   * create a vote account keypair                             ###"
echo "###   * link your Identity keypair to your Vote account keypair   ###"
echo "###   * copy your correct keypair to /home/solana/secrets         ###"
echo "###   * restart the validator node                                ###"
echo "#####################################################################"

backup_keys() {
  mv /home/solana/.secrets "/home/solana/.backup_secrets_$RANDOM"
}

copy_validator_key () {

  mkdir /home/solana/.secrets
  cp /root/validator-keypair.json /home/solana/.secrets/
  chown solana:solana -R /home/solana/.secrets/
  chmod 755 -R /home/solana/.secrets/

}

create_vote_account() {
  sudo -i -u solana solana-keygen new --silent --no-bip39-passphrase --outfile /home/solana/.secrets/vote-account-keypair.json
  sudo -i -u solana solana create-vote-account /home/solana/.secrets/vote-account-keypair.json /home/solana/.secrets/validator-keypair.json --keypair /home/solana/.secrets/validator-keypair.json
}

systemctl stop solana-validator
backup_keys
copy_validator_key
create_vote_account
systemctl start solana-validator
