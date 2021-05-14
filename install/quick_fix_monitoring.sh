#!/bin/bash
#set -x -e

echo "###################### WARNING!!! ######################"
echo "###   This script will install and/or reconfigure    ###"
echo "### telegraf and point it to solana.thevalidators.io ###"
echo "########################################################"

apt-get install coreutils --yes

sed -i 's/15s/60s/' /etc/telegraf/telegraf.conf
sed -i 's/30s/60s/' /etc/telegraf/telegraf.conf
sed -i 's/sudo -i -u/timeout -k 50 45 sudo -i -u/' /etc/telegraf/telegraf.conf

systemctl restart telegraf
