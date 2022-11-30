
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

echo "Uninstalling old versions of docker"
sudo apt-get remove docker docker-engine docker.io containerd runc

echo "Installing dependencies"

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Adding official docker GPG key"

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating packages list..."
sudo apt-get update

echo "Installing docker and docker-compose..."
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Setting up user permissions..."
sudo groupadd docker

sudo usermod -aG docker ${USER}

newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

echo "All done! Running a test..."

docker run hello-world
