#!/bin/bash

# This script is meant to be run on on your machine and it runs other scripts on remote machines.

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

ssh_status=1  # As init

while [[ ! $ssh_status -eq 0 ]]; do
    # Get an actual IP address
    ip=0
    while [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; do
        read -p "IP: " ip
    done

    read -p "Username (for $ip): " user

    read -e -p "Gain access to remote? (Y/n) blank = no " choice
    echo ""
    if [[ $choice == y* ]]; then
        echo "You will be asked for a password twice..."
        # checking for ssh keys on system...
        if [ ! -f ~/.ssh/id_rsa.pub ]; then
            echo "Generating an ssh key for machine..."
            ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""
        fi
        echo "Gaining access to remote..."
        ssh-copy-id -i $HOME/.ssh/id_rsa.pub $user@$ip

        # Force sudo to not require a password
        echo "Forcing sudo to not require a password..."
        ssh -t $user$ip echo "$USER ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    fi

    # Test connection
    ssh -o BatchMode=yes -o ConnectTimeout=5 $user@$ip exit
    ssh_status=$?

    if ! [[ $ssh_status -eq 0 ]]; then
        echo "SSH connection to $ip is good"
    fi
done

echo "========================================"
echo "======= Connected to $ip ======="

while [ true ]; do
    echo "========================================"
    echo 'Choose a script from the following:'
    select script in scripts/*.sh; do test -n "$script" && break; echo ">>> Invalid Selection"; done
    echo ""

    echo "> Executing $script on $ip..."
    echo ""
    echo "----------------------------------------"
    echo ""
    ssh -t $user@$ip "bash -s" < $script
    echo ""
    echo "> Script $script executed!"
    echo ""
done
