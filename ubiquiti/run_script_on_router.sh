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

echo 'Choose router ip:'
select ip in $gateway_ips; do test -n "$ip" && break; echo ">>> Invalid Selection"; done
echo ""

read -p "Username (for $ip): " user
# read -s -p "Password (for $ip): " password
# echo ""

echo 'Choose a script from the following:'
select script in scripts/*; do test -n "$script" && break; echo ">>> Invalid Selection"; done
echo ""

echo 'Removing local keys belonging to router ip...'
ssh-keygen -R $ip
echo ""

if [[ "$script" == *"wireguard"* ]]; then
  if [[ "$script" == *"setup_wireguard"* ]]; then
    ./setup_temp_files.sh $ip $script 1 $user
  else
    ./setup_temp_files.sh $ip $script 0 $user
  fi
else
  ssh -o "StrictHostKeyChecking no" $user@$ip "/bin/vbash -s" < $script
fi