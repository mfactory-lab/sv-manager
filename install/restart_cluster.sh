#!/bin/bash
#set -x -e


update_validator() {

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

  ansible-galaxy collection install ansible.posix
  ansible-galaxy collection install community.general

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

  sed -i 's/\/\/testnet.solana.com/\/\/api.testnet.solana.com/g' /etc/sv_manager/sv_manager.conf

  wait_for_restart_window

  ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_cluster_restart.yaml --tags "$2" --extra-vars "@/etc/sv_manager/sv_manager.conf" --extra-vars 'host_hosts=local'

  catchup_info

  echo Do you want to Uninstall ansible?
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) $pkg_manager remove ansible --yes; break;;
          No ) echo "### Okay, ansible is still installed on this system.  ###"; break;;
      esac
  done
}

if [ -f /etc/sv_manager/sv_manager.conf ]
then
echo "### Validator has been already installed. Start update?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) update_validator "${1:-latest}" "${2:-""}"; break;;
        No ) echo "### Aborting update. No changes are made on the system."; exit;;
    esac
done
else
echo '### Validator is not installed, or the version is too old. ###'
echo '### Please run full install of the latest version using this command: ###'
echo '### /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mfactory-lab/sv-manager/latest/install/install_monitoring.sh)" ###'
fi
