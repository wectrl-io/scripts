#!/bin/vbash

# make sure script is run as group vyattacfg
echo "Changing shell..."
if [ $(id -gn) != vyattacfg ]; then
    exec sg vyattacfg "$0 $*"
fi

# vyatta-cfg-cmd-wrapper #
run=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$run begin
echo "Adding ssh key..."

echo "Setting key type..."
$run set system login user ubnt authentication public-keys setup type ssh-rsa

echo "Setting key..."
key_file=$( cat /tmp/ubnt.pub )
key_list=($key_file)

$run set system login user ubnt authentication public-keys setup key ${key_list[1]}

echo "Commiting and saving..."
$run commit
$run save
$run end
