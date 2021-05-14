#!/bin/bash
#set -x -e

echo "###################### WARNING!!! ######################"
echo "###   This script will install and/or reconfigure    ###"
echo "### telegraf and point it to solana.thevalidators.io ###"
echo "########################################################"

install_monitoring () {

  if [[ $(which apt | wc -l) -gt 0 ]]
  then
    pkg_manager=apt
  elif [[ $(which yum | wc -l) -gt 0 ]]
  then
    pkg_manager=yum
  fi

  echo "Update packages..."
  $pkg_manager update
  echo "Install ansible, curl, unzip..."
  $pkg_manager install ansible curl unzip --yes

  echo "Download Solana validator manager"
  curl -fsSL https://github.com/mfactory-lab/sv-manager/archive/refs/tags/latest.zip --output sv_manager.zip
  echo "Unpack Solana validator manager"
  unzip ./sv_manager.zip -d .

  mv sv-manager* sv_manager
  rm ./sv_manager.zip
  cd ./sv_manager
  cp -r ./inventory_example ./inventory

  ansible-playbook --connection=local \
  --inventory ./inventory \
  --limit local  playbooks/pb_install_monitoring.yaml \
  --extra-vars "{'host_hosts': 'local'}" \
  --tags monitoring.script.library

  echo "### Updating telegraf config ###"

  sed -i 's/15s/60s/' /etc/telegraf/telegraf.conf
  sed -i 's/30s/60s/' /etc/telegraf/telegraf.conf

  echo "### Restarting telegraf config ###"

  systemctl restart telegraf

  echo "### Cleanup install folder ###"
  cd ..
  rm -r ./sv_manager
  echo "### Cleanup install folder done ###"

  echo "### Remove Ansible ###"
  $pkg_manager remove ansible --yes;
  echo "### Remove Ansible done ###"

}

echo Do you want to update monitoring?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_monitoring; break;;
        No ) echo "Aborting install. No changes are made on the system."; exit;;
    esac
done



