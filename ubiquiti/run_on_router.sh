#!/bin/bash
# Run from PC

# Determine OS
case "$OSTYPE" in
  solaris*) os="SOLARIS" ;;
  darwin*)  os="MAC" ;;
  linux*)   os="LINUX" ;;
  bsd*)     os="BSD" ;;
  msys*)    os="WINDOWS" ;;
  cygwin*)  os="WINDOWS" ;;
  *)        os="unknown: $OSTYPE" ;;
esac

echo "Host OS: $os"
echo ""

case "$os" in
  "MAC") gateway_ips=($( netstat -rn | grep en | grep default | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1' )) ;;
  "LINUX") gateway_ips=($( ip r | grep default | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1' ))
esac

echo 'Choose router ip (0 for exit):'
select ip in $gateway_ips
    do test -n "$ip" && break;
    if [ '0' -eq $REPLY ]; then
            echo ">>> Exiting"
            exit 0
    fi
    echo ">>> Invalid Selection"
done
echo ""

read -p "Username (for $ip): " user
# read -s -p "Password (for $ip): " password
# echo ""

echo 'Removing local keys belonging to router ip...'
ssh-keygen -R $ip
echo ""

# Ask user if they want to copy public key to router
read -e -p "Copy public key to router? (Y/n) blank = no " choice
echo ""
if [[ $choice == y* ]]; then
    echo "Gaining access to router..."
    
    # Send public ssh key to router
    scp ~/.ssh/id_rsa.pub $user@$ip:/tmp/ubnt.pub

    # Execute script to add public key on router
    ssh -o "StrictHostKeyChecking no" $user@$ip "/bin/vbash -s" < scripts/helpers/init_ssh_key.sh
fi

echo 'Choose a script from the following:'
select script in scripts/*; do test -n "$script" && break; echo ">>> Invalid Selection"; done
echo ""

# Scripts pre-launch #

# Setup Wireguard
if [[ "$script" == *"wireguard"* ]]; then
  if [[ "$script" == *"setup_wireguard"* ]]; then
    ./scripts/helpers/setup_temp_files_wg.sh $ip $script 1 $user
  else
    ./scripts/helpers/setup_temp_files_wg.sh $ip $script 0 $user
  fi
else
  # Execute script on remote
  ssh -o "StrictHostKeyChecking no" $user@$ip "/bin/vbash -s" < $script
fi

# Scripts post-launch #

if [[ "$script" == *"wireguard"* ]]; then
  if [[ "$script" == *"setup_wireguard"* ]]; then
    echo "Pulling new files from setup script..."
    scp $user@$ip:/tmp/wg_configs ./output/wg_configs
  fi
fi