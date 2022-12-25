#!/bin/vbash

# make sure script is run as group vyattacfg
echo "Changing shell..."
if [ $(id -gn) != vyattacfg ]; then
    exec sg vyattacfg "$0 $*"
fi

# vyatta-cfg-cmd-wrapper #
run=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$run begin
$run loadkey ubnt /tmp/ubnt.pub  # Not working
echo "Commiting and saving..."
$run commit
$run save
$run end