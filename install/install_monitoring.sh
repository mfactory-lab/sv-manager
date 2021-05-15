#!/bin/bash
#set -x -e

echo "###################### WARNING!!! ######################"
echo "###   This script will install and/or reconfigure    ###"
echo "### telegraf and point it to solana.thevalidators.io ###"
echo "########################################################"

install_monitoring () {

    rm -rf sv_manager/

  if [[ $(which apt | wc -l) -gt 0 ]]
  then
  pkg_manager=apt
  elif [[ $(which yum | wc -l) -gt 0 ]]
  then
  pkg_manager=yum
  fi

  echo "### Update packages... ###"
  $pkg_manager update
  echo "### Install ansible, curl, unzip... ###"
  $pkg_manager install ansible curl unzip --yes

  echo "### Download Solana validator manager"
  cmd="https://github.com/mfactory-lab/sv-manager/archive/refs/tags/$1.zip"
  echo "starting $cmd"
  curl -fsSL "$cmd" --output sv_manager.zip
  echo "### Unpack Solana validator manager ###"
  unzip ./sv_manager.zip -d .

  mv sv-manager* sv_manager
  rm ./sv_manager.zip
  cd ./sv_manager || exit
  cp -r ./inventory_example ./inventory

  echo "### Which cluster you wnat to monitor? ###"
  select cluster in "mainnet-beta" "testnet"; do
      case $cluster in
          mainnet-beta ) entry_point="https://api.mainnet-beta.solana.com"; break;;
          testnet ) entry_point="https://api.testnet.solana.com"; break;;
      esac
  done


  echo "### Please type your validator name: "
  read VALIDATOR_NAME
  echo "### Please type the full path to your validator keys: "
  read PATH_TO_VALIDATOR_KEYS

  read -e -p "### Please tell which user is running validator: " SOLANA_USER
  #echo $(pwd)
  ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_config.yaml --extra-vars "{'host_hosts': 'local', 'solana_user': '$SOLANA_USER', 'validator_name':'$VALIDATOR_NAME','secrets_path':'$PATH_TO_VALIDATOR_KEYS', 'cluster_rpc_address':'$entry_point'}"

  ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_install_monitoring.yaml --extra-vars "@/etc/sv_manager/sv_manager.conf" --extra-vars 'host_hosts=local'

  echo "### Cleanup install folder ###"
  cd ..
  rm -r ./sv_manager
  echo "### Cleanup install folder done ###"
  echo "### Check your dashboard: https://solana.thevalidators.io/d/e-8yEOXMwerfwe/solana-monitoring-v1-0-preview?&var-server="$VALIDATOR_NAME

  echo Do you want to UNinstall ansible?
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) $pkg_manager remove ansible --yes; break;;
          No ) echo "### Okay, ansible is still installed on this system.  ###"; break;;
      esac
  done

}

echo Do you want to install monitoring?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_monitoring "${1:-latest}"; break;;
        No ) echo "### Aborting install. No changes are made on the system."; exit;;
    esac
done
