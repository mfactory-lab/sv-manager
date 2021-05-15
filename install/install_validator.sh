#!/bin/bash
#set -x -e

echo "###################### WARNING!!! ######################"
echo "###   This script will bootstrap a validator node    ###"
echo "###   for the Solana Testnet cluster, and connect    ###"
echo "###   it to the monitoring dashboard                 ###"
echo "###   at solana.thevalidators.io                     ###"
echo "########################################################"

install_monitoring () {

  if [[ $(which apt | wc -l) -gt 0 ]]
  then
  pkg_manager=apt
  elif [[ $(which yum | wc -l) -gt 0 ]]
  then
  pkg_manager=yum
  fi

  echo "Updating packages..."
  $pkg_manager update
  echo "Installing ansible, curl, unzip..."
  $pkg_manager install ansible curl unzip --yes

  ansible-galaxy collection install ansible.posix
  ansible-galaxy collection install community.general

  echo "Downloading Solana validator manager"
  curl -fsSL https://github.com/mfactory-lab/sv-manager/archive/refs/tags/latest.zip --output sv_manager.zip
  echo "Unpacking"
  unzip ./sv_manager.zip -d .

  mv sv-manager* sv_manager
  rm ./sv_manager.zip
  cd ./sv_manager
  cp -r ./inventory_example ./inventory

  entry_point="https://testnet.solana.com"

  echo "Please enter a name for your validator node: "
  read VALIDATOR_NAME
  read -e -p "Please enter the full path to your validator key pair file: " -i "/root/" PATH_TO_VALIDATOR_KEYS
  read -e -p "Enter new RAM drive size, GB (recommended size: server RAM minus 16GB):" -i "48" RAM_DISK_SIZE
  read -e -p "Enter new server swap size, GB (recommended size: equal to server RAM): " -i "64" SWAP_SIZE

  ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_config.yaml --extra-vars "{'host_hosts': 'local', \
  'validator_name':'$VALIDATOR_NAME', \
  'local': {'secrets_path': '$PATH_TO_VALIDATOR_KEYS', 'flat_path': 'True'}, \
  'cluster_rpc_address':'$entry_point', \
  'swap_file_size_gb': $SWAP_SIZE, \
  'ramdisk_size_gb': $RAM_DISK_SIZE, \
  'solana_user': 'solana', 'set_validator_info': 'False' \
  }"

  ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_install_validator.yaml --extra-vars "@/etc/sv_manager/sv_manager.conf"

  echo "### 'Uninstall ansible ###"

  $pkg_manager remove ansible --yes
  
  echo "Finished. Check your validator stats on https://solana.thevalidators.io"

}

echo "This script will bootstrap a Solana validator node. Proceed?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_monitoring; break;;
        No ) echo "Aborting install. No changes will be made."; exit;;
    esac
done
