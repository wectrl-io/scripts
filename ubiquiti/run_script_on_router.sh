#!/bin/bash
# Run from PC

# echo 'Choose router ip:'
# gateway_ips=($(netstat -rn | grep en | grep default | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1' ))
# select ip in $gateway_ips; do test -n "$ip" && break; echo ">>> Invalid Selection"; done
ip="10.1.1.1"

# echo 'Choose a script from the following:'
# select script in scripts/*; do test -n "$script" && break; echo ">>> Invalid Selection"; done
script=scripts/setup_wireguard.sh

echo 'Removing local keys belonging to router ip...'
ssh-keygen -R $ip

echo 'Sending script to router via ssh...'

ssh ubnt@$ip "/bin/vbash -s" < $script
