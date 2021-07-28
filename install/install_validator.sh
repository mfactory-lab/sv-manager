#!/bin/bash
#set -x -e

echo "###################### WARNING!!! ######################"
echo "###   This script will bootstrap a validator node    ###"
echo "###   for the Solana Testnet cluster, and connect    ###"
echo "###   it to the monitoring dashboard                 ###"
echo "###   at solana.thevalidators.io                     ###"
echo "########################################################"

install_validator () {

  rm -rf sv_manager/

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

  echo "Downloading Solana validator manager version $1"
  cmd="https://github.com/mfactory-lab/sv-manager/archive/refs/tags/$1.zip"
  echo "starting $cmd"
  curl -fsSL "$cmd" --output sv_manager.zip
  echo "Unpacking"
  unzip ./sv_manager.zip -d .

  mv sv-manager* sv_manager
  rm ./sv_manager.zip
  cd ./sv_manager || exit
  cp -r ./inventory_example ./inventory

  echo "### Which cluster do you want to monitor? ###"
  select cluster in "mainnet-beta" "testnet"; do
      case $cluster in
          mainnet-beta )
            cluster_environment="mainnet-beta"
            cluster_rpc_address="https://api.mainnet-beta.solana.com"
            version="v1.6.20"
            break;;
          testnet )
            cluster_environment="testnet"
            cluster_rpc_address="https://api.testnet.solana.com"
            version="v1.7.8"
            break;;
      esac
  done

  echo "Please enter a name for your validator node: "
  read VALIDATOR_NAME
  read -e -p "Please enter the full path to your validator key pair file: " -i "/root/" PATH_TO_VALIDATOR_KEYS

  if [ ! -f "$PATH_TO_VALIDATOR_KEYS/validator-keypair.json" ]
  then
    echo "key $PATH_TO_VALIDATOR_KEYS/validator-keypair.json not found. Pleas verify and run the script again"
    exit
  fi

  read -e -p "Enter new RAM drive size, GB (recommended size: server RAM minus 16GB):" -i "48" RAM_DISK_SIZE
  read -e -p "Enter new server swap size, GB (recommended size: equal to server RAM): " -i "64" SWAP_SIZE

  # shellcheck disable=SC2154
  echo "pwd: $(pwd)"
  ls -lah ./

  ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_config.yaml --extra-vars "{'host_hosts': 'local', \
  'validator_name':'$VALIDATOR_NAME', \
  'local_secrets_path': '$PATH_TO_VALIDATOR_KEYS', \
  'flat_path': 'True', \
  'cluster_environment':'$cluster_environment', \
  'cluster_rpc_address': '$cluster_rpc_address', \
  'swap_file_size_gb': $SWAP_SIZE, \
  'ramdisk_size_gb': $RAM_DISK_SIZE, \
  'solana_user': 'solana', \
  'set_validator_info': 'False', \
  'version': '$version'
  }"

  ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_install_validator.yaml --extra-vars 'host_hosts=local' --extra-vars "@/etc/sv_manager/sv_manager.conf"

  echo "### 'Uninstall ansible ###"

  $pkg_manager remove ansible --yes
  
  echo "### Check your dashboard: https://solana.thevalidators.io/d/e-8yEOXMwerfwe/solana-monitoring-v1-0-preview?&var-server=$VALIDATOR_NAME"

}

sv_version=${1:-latest}

echo "installing sv manager version $sv_version"

echo "This script will bootstrap a Solana validator node. Proceed?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_validator "$sv_version"; break;;
        No ) echo "Aborting install. No changes will be made."; exit;;
    esac
done
