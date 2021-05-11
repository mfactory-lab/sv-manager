#!/bin/bash
set -x -e

echo ###################### WARNING!!! ######################
echo ###   This script will install and/or reconfigure    ###
echo ### telegraf and point it to solana.thevalidators.io ###
echo ########################################################

install_monitoring () {

if [[ $(which apt | wc -l) -gt 0 ]]
then
pkg_manager=apt
elif [[ $(which yum | wc -l) -gt 0 ]]
then
pkg_manager=yum
fi

echo "Update apt packages..."
$pkg_manager update
echo "Install ansible.."
$pkg_manager install ansible curl unzip

echo "Download Solana validator manager"
curl -fsSL https://github.com/mfactory-lab/sv-manager/archive/refs/heads/feature/shell_scripts.zip --output sv_manager.zip
echo "Unpack Solana validator manager"
unzip sv_manager.zip -d .

mv sv-manager* sv_manager

cd ./sv_manager
cp -r ./inventory_example ./inventory

echo Which cluster you wnat to monitor?
select cluster in "mainnet-beta" "testnet"; do
    case $cluster in
        mainnet-beta ) entry_point="http://localhost:8089"; break;;
        testnet ) entry_point="https://testnet.colana.com"; break;;
    esac
done


echo "Please type your validator name: "
read VALIDATOR_NAME
echo "Please type the full path to your validator keys: "
read PATH_TO_VALIDATOR_KEYS

ansible-playbook --connection=local --inventory ./inventory --limit local  install_solana_monitoring_local.yaml -e "{'validator_name':'$VALIDATOR_NAME','secrets_path':'$PATH_TO_VALIDATOR_KEYS', 'rpc_address':'$entry_point'}"

cd /
echo "### Cleanup install folder ###"
rm -r /tmp/install
echo "### Cleanup install folder done ###"

}

echo Do you want to install monitoring?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_monitoring; break;;
        No ) exit;;
    esac
done