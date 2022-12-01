#!/bin/sh

echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y
echo ""

echo "Uninstalling old versions of docker"
sudo apt-get remove docker docker-engine docker.io containerd runc -y
echo ""

echo "Installing dependencies"

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
echo ""

echo "Adding official docker GPG key"

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo""

echo "Updating packages list..."
sudo apt-get update
echo ""

echo "Installing docker and docker-compose..."
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
echo ""

echo "Creating docker group..."
sudo groupadd docker
echo ""

echo "Adding current user to group docker..."
sudo usermod -aG docker ${USER}
echo ""

echo "Enabling docker services..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
echo ""

echo "Refreshing groups"
newgrp docker << END
echo ""
echo "All done! Running a test..."
echo ""
docker run hello-world
END
