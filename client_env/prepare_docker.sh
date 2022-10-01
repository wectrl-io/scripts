
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

curl -sSl https://get.docker.com | sh

sudo usermod -aG docker ${USER}

echo "Rebooting system..."
read -t 5 -p "I am going to wait for 5 seconds only ..."
sudo shutdown -r now
