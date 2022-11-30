
echo "Setting up reqired packages..."
sudo apt-get install -y libffi-dev libssl-dev python3-dev python3 python3-pip

echo "Installing docker-compose..."
sudo pip3 install setuptools_rust docker-compose

echo "Enabling docker on boot"
sudo systemctl enable docker

echo "Running test container"
docker run hello-world
