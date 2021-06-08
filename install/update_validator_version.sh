#!/bin/bash
#set -x -e

echo "###################### WARNING!!! ###################################"
echo "###   This script will perform the following operations:          ###"
echo "###   * wait for validator restart window                         ###"
echo "###   * download version 1.7.1                                    ###"
echo "###   * restart sys tuner service                                 ###"
echo "###   * restart validator service                                 ###"
echo "###   * wait for catchup                                          ###"
echo "#####################################################################"

update_validator() {
  if [ -d /mnt/ledger ]
  then
    sudo -i -u solana bash -c "$(echo 'set -x &&  cd /mnt && solana-validator wait-for-restart-window')"
  else
    if [ -d /mnt/ramdisk/solana/ledger/ ]
    then
      sudo -i -u solana bash -c "$(echo 'set -x &&  cd /mnt/ramdisk/solana/ && solana-validator wait-for-restart-window')"
    else
      sudo -i -u solana solana-validator wait-for-restart-window
    fi
  fi
  sudo -i -u solana solana-install init "$version"
  systemctl restart solana-sys-tuner
  systemctl restart solana-validator
  sudo -i -u solana solana config set -ut
}

catchup_info() {

  while true; do

    sudo -i -u solana solana catchup .secrets/validator-keypair.json --our-localhost
    status=$?

    if [ $status -eq 0 ]
    then
      exit 0
    fi

    echo "waiting next 30 seconds for rpc"
    sleep 30

  done

}

version=${1:-latest}

echo "updating to version $version"

update_validator
catchup_info
