#!/bin/bash
#set -x -e
set -e

echo "###################### WARNING!!! ###################################"
echo "###   This script will perform the following operations:          ###"
echo "###   * wait for validator restart window                         ###"
echo "###   * download version 1.6.9                                    ###"
echo "###   * restart sys tuner service                                 ###"
echo "###   * restart validator service                                 ###"
echo "###   * wait for catchup                                          ###"
echo "#####################################################################"



update_validator() {
  #sudo -i -u solana solana-validator --ledger path exit --min-idle-time 12
  sudo -i -u solana solana-validator wait-for-restart-window
  sudo -i -u solana solana-install init "$version"
  systemctl restart solana-sys-tuner
  systemctl restart solana-validator
}

catchup_info() {

  while true; do

    sudo -i -u solana solana catchup .secrets/validator-keypair.json --our-localhost
    status=$?

    if [ $status -eq 0 ]
    then
      exit 0
    fi

  done

}

version=${1:-latest}

echo "updating to version $version"

update_validator
catchup_info
