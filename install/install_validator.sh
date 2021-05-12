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

ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general

echo "Download Solana validator manager"
curl -fsSL https://github.com/mfactory-lab/sv-manager/archive/refs/tags/0.0.1-SNAPSHOT.zip --output sv_manager.zip
echo "Unpack Solana validator manager"
unzip ./sv_manager.zip -d .

mv sv-manager* sv_manager
rm ./sv_manager.zip
cd ./sv_manager
cp -r ./inventory_example ./inventory

echo "Which cluster you want to install monitoring node (select number)?"
select cluster in "mainnet-beta" "testnet"; do
    case $cluster in
        mainnet-beta ) entry_point="https://api.mainnet-beta.solana.com"; break;;
        testnet ) entry_point="https://testnet.solana.com"; break;;
    esac
done


echo "Please type your validator name: "
read VALIDATOR_NAME
read -e -p "Please type the full path to your validator keys: " -i "/root/" PATH_TO_VALIDATOR_KEYS
read -e -p "Enter size of new ram-drive in GB (should be server ram-amount minus 16GB): " -i "48" RAM_DISK_SIZE
read -e -p "Enter size of server new swap in GB (should be eq to ram-amount): " -i "64" SWAP_SIZE


pb_params="{'host_hosts': 'local', \
'validator_name':'$VALIDATOR_NAME', \
'local': {'secrets_path': '$PATH_TO_VALIDATOR_KEYS', 'flat_path': 'True'}, \
'rpc_address':'$entry_point', \
'swap_file_size_gb': '$SWAP_SIZE', \
'ramdisk_size_gb': '$RAM_DISK_SIZE', \
'solana_user': 'solana', 'set_validator_info': 'False'
}"

ansible-playbook --connection=local --inventory ./inventory --limit local  playbooks/pb_install_validator.yaml -e $pb_params -v

echo "### Cleanup install folder ###"
cd ..
rm -r ./sv_manager
echo "### Cleanup install folder done ###"

echo Do you want to UNinstall ansible?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) $pkg_manager remove ansible --yes; break;;
        No ) echo "Okay, ansible is still installed on this system."; break;;
    esac
done

}

echo Do you want to install monitoring?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_monitoring; break;;
        No ) echo "Aborting install. No changes are made on the system."; exit;;
    esac
done
