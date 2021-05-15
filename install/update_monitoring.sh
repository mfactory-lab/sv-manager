#!/bin/bash
#set -x -e

update_monitoring() {

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
#curl -fsSL https://github.com/mfactory-lab/sv-manager/archive/refs/tags/latest.zip --output sv_manager.zip
curl -fsSL https://github.com/Rossignolskier/sv-manager/archive/refs/heads/develop.zip --output sv_manager.zip
echo "### Unpack Solana validator manager ###"
unzip ./sv_manager.zip -d .

mv sv-manager* sv_manager
rm ./sv_manager.zip
cd ./sv_manager
cp -r ./inventory_example ./inventory

ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_install_monitoring.yaml --tags telegraf.configure,monitoring.script --extra-vars "@/etc/sv_manager/sv_manager.conf" --extra-vars 'host_hosts=local'
}

if [ -f /etc/sv_manager/sv_manager.conf ]
then
echo "### Monitoring has been already installed. Start update?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) update_monitoring; break;;
        No ) echo "### Aborting update. No changes are made on the system."; exit;;
    esac
done
else
echo '### Monitoring is not installed, or the version is too old. ###'
echo '### Please run full install of the latest version using this command: ###'
echo '### /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mfactory-lab/sv-manager/latest/install/install_monitoring.sh)" ###'
fi
