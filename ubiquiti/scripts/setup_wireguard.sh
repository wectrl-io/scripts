#!/bin/vbash

# For Ubiquiti EdgeRouter X

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

wg genkey | tee /config/auth/peer3.private | wg pubkey > /config/auth/peer3.public
openssl rand -base64 32 > /config/auth/peer3.preshared

# Session #
# make sure script is run as group vyattacfg
if [ 'vyattacfg' != $(id -ng) ]; then
 exec sg vyattacfg -c "$0 $@"
fi

# vyatta-cfg-cmd-wrapper #
run=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$run begin

echo "Setting up WireGuard interface..."
$run set interfaces wireguard wg0 address $( cat /tmp/wg/wg0_ip )/24
$run set interfaces wireguard wg0 listen-port $( cat /tmp/wg/port_num )
$run set interfaces wireguard wg0 route-allowed-ips true
$run set interfaces wireguard wg0 private-key /config/auth/wg0.private

echo "Adding peers..."
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer1.public ) endpoint $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer1.public ) allowed-ips $( cat /tmp/wg/peer1_ip )/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer1.public ) preshared-key $( cat /config/auth/peer1.preshared )
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer1.public ) description "Peer 1"

$run set interfaces wireguard wg0 peer $( cat /config/auth/peer2.public ) endpoint $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer2.public ) allowed-ips $( cat /tmp/wg/peer2_ip )/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer2.public ) preshared-key $( cat /config/auth/peer2.preshared )
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer2.public ) description "Peer 2"

$run set interfaces wireguard wg0 peer $( cat /config/auth/peer3.public ) endpoint $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer3.public ) allowed-ips $( cat /tmp/wg/peer3_ip )/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer3.public ) preshared-key $( cat /config/auth/peer3.preshared )
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer3.public ) description "Peer 3"

echo "Setting up firewall..."
$run set firewall name WAN_LOCAL rule 20 action accept
$run set firewall name WAN_LOCAL rule 20 protocol udp
$run set firewall name WAN_LOCAL rule 20 description 'WireGuard'
$run set firewall name WAN_LOCAL rule 20 destination port $( cat /tmp/wg/port_num )

echo "Setup DNS to work on VPN..."
$run set service dns forwarding listen-on wg0

echo "Commiting and saving..."
$run commit
$run save
$run end


echo ""
echo ""
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
echo ''
echo "Peer3 Private Key:"
cat /config/auth/peer3.private
echo "Peer3 Public Key:"
cat /config/auth/peer3.public
echo "Peer3 preshared Key:"
cat /config/auth/peer3.preshared


echo "====="

echo "-----"
echo "peer1 config:"
echo ""
echo "[Interface]"
echo "PrivateKey = $(cat /config/auth/peer1.private)"
echo "ListenPort = $( cat /tmp/wg/port_num )"
echo "Address = $( cat /tmp/wg/peer1_ip )/24"
echo "DNS = $( cat /tmp/wg/dns )"
echo ""
echo "[Peer]"
echo "PublicKey = $(cat /config/auth/wg0.public)"
echo "PresharedKey = $(cat /config/auth/peer1.preshared)"
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )"
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )"  # Ext ip

echo "-----"
echo "peer2 config:"
echo ""
echo "[Interface]"
echo "PrivateKey = $(cat /config/auth/peer2.private)"
echo "ListenPort = $( cat /tmp/wg/port_num )"
echo "Address = $( cat /tmp/wg/peer2_ip )/24"
echo "DNS = $( cat /tmp/wg/dns )"
echo ""
echo "[Peer]"
echo "PublicKey = $(cat /config/auth/wg0.public)"
echo "PresharedKey = $(cat /config/auth/peer2.preshared)"
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )"
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )"  # Ext ip

echo "-----"
echo "peer3 config:"
echo ""
echo "[Interface]"
echo "PrivateKey = $(cat /config/auth/peer3.private)"
echo "ListenPort = $( cat /tmp/wg/port_num )"
echo "Address = $( cat /tmp/wg/peer3_ip )/24"
echo "DNS = $( cat /tmp/wg/dns )"
echo ""
echo "[Peer]"
echo "PublicKey = $(cat /config/auth/wg0.public)"
echo "PresharedKey = $(cat /config/auth/peer3.preshared)"
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )"
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )"  # Ext ip
