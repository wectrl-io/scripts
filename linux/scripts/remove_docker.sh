#!/bin/sh
read -p "This scripts uninstalls docker from the system. Do you wish to continue? (y/n) " RESP
if [ "$RESP" = "y" ]; then
  echo ""
else
  echo "Exiting..."
  exit
fi

echo "Uninstalling docker..."

dpkg -l | grep -i docker
sudo apt remove --purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo apt autoremove -y
sudo apt autoclean