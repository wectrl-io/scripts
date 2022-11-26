#!/bin/zsh
# Run from PC

echo 'Choose router ip:'
gateway_ips=($(netstat -rn | grep en | grep default | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1' ))
select ip in $gateway_ips; do test -n "$ip" && break; echo ">>> Invalid Selection"; done

# echo 'Choose a script from the following:'
# select script in scripts/*; do test -n "$script" && break; echo ">>> Invalid Selection"; done

echo 'Removing local keys belonging to router ip...'
ssh-keygen -R $ip

echo 'Sending script to router via ssh...'

ssh ubnt@$ip "/bin/vbash -s" < scripts/setup_wireguard.sh
# ssh ubnt@$ip < $script
