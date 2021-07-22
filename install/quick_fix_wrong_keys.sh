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
  cp "$PATH_TO_VALIDATOR_KEYS/validator-keypair.json" /home/solana/.secrets/
  chown solana:solana -R /home/solana/.secrets/
  chmod 755 -R /home/solana/.secrets/

}

create_vote_account() {
  sudo -i -u solana solana-keygen new --silent --no-bip39-passphrase --outfile /home/solana/.secrets/vote-account-keypair.json
  sudo -i -u solana solana create-vote-account /home/solana/.secrets/vote-account-keypair.json /home/solana/.secrets/validator-keypair.json --keypair /home/solana/.secrets/validator-keypair.json
  sudo -i -u solana solana vote-account .secrets/vote-account-keypair.json
}

echo "### Please type the full path to your ORIGINAL validator keys: "
read -r PATH_TO_VALIDATOR_KEYS

if [ ! -f "$PATH_TO_VALIDATOR_KEYS/validator-keypair.json" ]
then
  echo "key $PATH_TO_VALIDATOR_KEYS/validator-keypair.json not found. Pleas verify and run the script again"
  exit
fi

systemctl stop solana-validator
backup_keys
copy_validator_key
create_vote_account
systemctl start solana-validator
