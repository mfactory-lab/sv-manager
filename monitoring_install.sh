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

echo "DOWNLOAD Solana validator manager"
curl -fsSL https://github.com/mfactory-lab/sv-manager/archive/refs/heads/feature/shell_scripts.zip --output sv_manager.zip
echo "Unpack"
unzip sv_manager.zip -d .

cd ./sv-manager-feature-shell_scripts

echo Which cluster you wnat to monitor?
select cluster in "mainnet-beta" "testnet"; do
    case $cluster in
        mainnet-beta ) entry_point="http://localhost:8089"; break;;
        testnet ) entry_point="https://testnet.solana.com"; break;;
    esac
done


echo "Please type your validator name: "
read VALIDATOR_NAME
echo "Please type the full path to your validator keys: "
read PATH_TO_VALIDATOR_KEYS

ansible-playbook --connection=local --inventory ./inventory --limit local  pb_install_monitoring_local.yaml -e validator.name=$VALIDATOR_NAME -e validator.secrets_path=$PATH_TO_VALIDATOR_KEYS -e cluster.rpc_address=$entry_point

}

echo Do you want to install monitoring?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_monitoring; break;;
        No ) exit;;
    esac
done


