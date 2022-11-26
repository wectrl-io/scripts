#!/bin/vbash

# Install
cd /tmp
curl -OL https://github.com/WireGuard/wireguard-vyatta-ubnt/releases/download/1.0.20220627-1/e50-v2-v1.0.20220627-v1.0.20210914.deb
sudo dpkg -i e50-v2-v1.0.20220627-v1.0.20210914.deb

# Setup 
wg genkey | tee /config/auth/wg0.private | wg pubkey >  /config/auth/wg0.public

wg genkey | tee /config/auth/peer1.private | wg pubkey > /config/auth/peer1.public
openssl rand -base64 32 > /config/auth/peer1.preshared

wg genkey | tee /config/auth/peer2.private | wg pubkey > /config/auth/peer2.public
openssl rand -base64 32 > /config/auth/peer2.preshared

# read -p 'External IP: ' ext_ip

# Session #
# make sure script is run as group vyattacfg
if [ 'vyattacfg' != $(id -ng) ]; then
 exec sg vyattacfg -c "$0 $@"
fi

# vyatta-cfg-cmd-wrapper #
run=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$run begin

echo "Setting up WireGuard interface..."
$run set interfaces wireguard wg0 address 10.11.1.1/24
$run set interfaces wireguard wg0 listen-port 51820
$run set interfaces wireguard wg0 route-allowed-ips true
$run set interfaces wireguard wg0 private-key /config/auth/wg0.private

echo "Adding peers..."
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer1.public ) endpoint 109.199.153.247:51820  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer1.public ) allowed-ips 192.11.1.2/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer1.public ) preshared-key $( cat /config/auth/peer1.preshared )

$run set interfaces wireguard wg0 peer $( cat /config/auth/peer2.public ) endpoint 109.199.153.247:51820  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer2.public ) allowed-ips 10.11.1.3/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer2.public ) preshared-key $( cat /config/auth/peer2.preshared )

echo "Setting up firewall..."
$run set firewall name WAN_LOCAL rule 20 action accept
$run set firewall name WAN_LOCAL rule 20 protocol udp
$run set firewall name WAN_LOCAL rule 20 description 'WireGuard'
$run set firewall name WAN_LOCAL rule 20 destination port 51820

echo "Commiting and saving..."
$run commit
$run save
$run end

echo "--- WG Info ---"
echo "WG Server Private Key:"
cat /config/auth/wg0.private
echo "WG Server Public Key:"
cat /config/auth/wg0.public
echo ""
echo "Peer1 Private Key:"
cat /config/auth/peer1.private
echo "Peer1 Public Key:"
cat /config/auth/peer1.public
echo "Peer1 preshared Key:"
cat /config/auth/peer1.preshared
echo ''
echo "Peer2 Private Key:"
cat /config/auth/peer2.private
echo "Peer2 Public Key:"
cat /config/auth/peer2.public
echo "Peer2 preshared Key:"
cat /config/auth/peer2.preshared


echo "====="

echo "-----"
echo "peer1 config:"
echo ""
echo "[Interface]"
echo "PrivateKey = $(cat /config/auth/peer1.private)"
echo "ListenPort = 51820"
echo "Address = 10.11.1.2/24"
echo "DNS = 1.1.1.1"
echo ""
echo "[Peer]"
echo "PublicKey = $(cat /config/auth/wg0.public)"
echo "PresharedKey = $(cat /config/auth/peer1.preshared)"
echo "AllowedIPs = 10.11.1.1/32, 10.1.1.0/24"
echo "Endpoint = 109.199.153.247:51820"  # Ext ip

echo "-----"
echo "peer2 config:"
echo ""
echo "[Interface]"
echo "PrivateKey = $(cat /config/auth/peer2.private)"
echo "ListenPort = 51820"
echo "Address = 10.11.1.3/24"
echo "DNS = 1.1.1.1"
echo ""
echo "[Peer]"
echo "PublicKey = $(cat /config/auth/wg0.public)"
echo "PresharedKey = $(cat /config/auth/peer2.preshared)"
echo "AllowedIPs = 10.11.1.1/32, 10.1.1.0/24"
echo "Endpoint = 109.199.153.247:51820"  # Ext ip
