#!/bin/bash
#set -x -e

install_validator () {

#  rm -rf sv_manager/
#
#  if [[ $(which apt | wc -l) -gt 0 ]]
#  then
#  pkg_manager=apt
#  elif [[ $(which yum | wc -l) -gt 0 ]]
#  then
#  pkg_manager=yum
#  fi
#
#  echo "Updating packages..."
#  $pkg_manager update
#  echo "Installing ansible, curl, unzip..."
#  $pkg_manager install ansible curl unzip --yes

  ansible-galaxy collection install ansible.posix
  ansible-galaxy collection install community.general

#  echo "Downloading Solana validator manager version $sv_manager_version"
#  cmd="https://github.com/mfactory-lab/sv-manager/archive/refs/tags/$sv_manager_version.zip"
#  echo "starting $cmd"
#  curl -fsSL "$cmd" --output sv_manager.zip
#  echo "Unpacking"
#  unzip ./sv_manager.zip -d .
#
#  mv sv-manager* sv_manager
#  rm ./sv_manager.zip
#  cd ./sv_manager || exit
#
#  if [ ! -z $solana_version ]
#  then
#    SOLANA_VERSION="--extra-vars {\"solana_version\":\"$solana_version\"}"
#  fi
#  if [ ! -z $extra_vars ]
#  then
#    EXTRA_INSTALL_VARS="--extra-vars $extra_vars"
#  fi
#  if [ ! -z $tags ]
#  then
#    TAGS="--tags [$tags]"
#  fi
#
#  if [ ! -z $skip_tags ]
#  then
#    SKIP_TAGS="--skip-tags $skip_tags"
#  fi

  ansible-playbook --connection=local --inventory ./inventory_trinity01/testnet.yaml --limit localhost  playbooks/pb_config.yaml

  ansible-playbook --connection=local --inventory ./inventory_trinity01/testnet.yaml --limit localhost  playbooks/pb_install_validator.yaml --extra-vars "@/etc/sv_manager/sv_manager.conf"

  echo "### Check your dashboard: https://solana.thevalidators.io/d/e-8yEOXMwerfwe/solana-monitoring?&var-server=$VALIDATOR_NAME"

}


while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare ${param}="$2"
  #      echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

sv_manager_version=${sv_manager_version:-latest}

echo "installing sv manager version $sv_manager_version"

echo "This script will bootstrap a Solana validator node. Proceed?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_validator "$sv_manager_version" "$extra_vars" "$solana_version" "$tags" "$skip_tags"; break;;
        No ) echo "Aborting install. No changes will be made."; exit;;
    esac
done
