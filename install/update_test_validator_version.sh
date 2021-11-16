#!/bin/bash
#set -x -e

echo "###################### WARNING!!! ###################################"
echo "###   This script will perform the following operations:          ###"
echo "###   * wait for validator restart window                         ###"
echo "###   * validator binaries                                        ###"
echo "###   * restart sys tuner service                                 ###"
echo "###   * restart validator service                                 ###"
echo "###   * wait for catchup                                          ###"
echo "#####################################################################"

update_validator() {
  sudo -i -u solana solana-install init "$version"
  echo "Version "$version" successfully downloaded"
  systemctl restart solana-sys-tuner
  sudo -i -u solana solana config set -ut  

  echo "Searching for ledger directory..."
  l_path=$(find / -name admin.rpc | sed 's|/admin.rpc||')
  echo "Found ledger at "$l_path". Is it correct?"
  select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo -i -u solana solana-validator --ledger $l_path wait-for-restart-window; break;;
        No ) echo "### Aborting install. Please restart your solana services manually."; exit;;
    esac
done
  systemctl restart solana-validator
}

catchup_info() {

  while true; do

    sudo -i -u solana solana catchup --our-localhost
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
#read -e -p "### Please tell which user is running validator [solana]: " SOLANA_USER
#SOLANA_USER=${SOLANA_USER:-solana}
update_validator
catchup_info
