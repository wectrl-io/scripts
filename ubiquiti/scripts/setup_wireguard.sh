#!/bin/vbash
# For Ubiquiti Devices

### Setup ###
BOARD=e50 # EdgeRouter X

## OS Version
# OS=v1
OS=v2

#######################################################
# DO NOT EDIT BELOW THIS LINE
#######################################################
# Install 
if ! dpkg -s wireguard >/dev/null 2>&1; then
    echo "Installing WireGuard..."
    
    cd /tmp

    releases=$(curl "https://api.github.com/repos/WireGuard/wireguard-vyatta-ubnt/releases")
    tag=$(echo -E $releases | jq -r '.[0].tag_name' )
    prefix=$(echo -E $releases | jq -r '.[0].assets' | jq -r '.[0].name' | cut -d'-' -f3-)

    deb_url="https://github.com/WireGuard/wireguard-vyatta-ubnt/releases/download/$tag/$BOARD-$OS-$prefix"
    curl -L -o "/tmp/wireguard-$BOARD-$tag.deb" "$deb_url"

    sudo dpkg -i "/tmp/wireguard-$BOARD-$tag.deb"
    rm "/tmp/wireguard-$BOARD-$tag.deb"
fi

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
### DEBUG - START ###
# echo "WG Server Private Key:"
# cat /config/auth/wg0.private
# echo "WG Server Public Key:"
# cat /config/auth/wg0.public
# echo ""
# echo "Peer1 Private Key:"
# cat /config/auth/peer1.private
# echo "Peer1 Public Key:"
# cat /config/auth/peer1.public
# echo "Peer1 preshared Key:"
# cat /config/auth/peer1.preshared
# echo ''
# echo "Peer2 Private Key:"
# cat /config/auth/peer2.private
# echo "Peer2 Public Key:"
# cat /config/auth/peer2.public
# echo "Peer2 preshared Key:"
# cat /config/auth/peer2.preshared
# echo ''
# echo "Peer3 Private Key:"
# cat /config/auth/peer3.private
# echo "Peer3 Public Key:"
# cat /config/auth/peer3.public
# echo "Peer3 preshared Key:"
# cat /config/auth/peer3.preshared
### DEBUG - END ###

echo "Creating dir for configs and saving there..."
out_files_dir=/tmp/wg_configs
mkdir -p $out_files_dir

echo "Saving configs to $out_files_dir..."
echo "-----"
echo "peer1 config > $out_files_dir/peer1.conf" 
echo ""
echo "[Interface]" > $out_files_dir/peer1.conf
echo "PrivateKey = $(cat /config/auth/peer1.private)" >> $out_files_dir/peer1.conf
echo "ListenPort = $( cat /tmp/wg/port_num )" >> $out_files_dir/peer1.conf
echo "Address = $( cat /tmp/wg/peer1_ip )/24" >> $out_files_dir/peer1.conf
echo "DNS = $( cat /tmp/wg/dns )" >> $out_files_dir/peer1.conf
echo "" >> $out_files_dir/peer1.conf
echo "[Peer]" >> $out_files_dir/peer1.conf
echo "PublicKey = $(cat /config/auth/wg0.public)" >> $out_files_dir/peer1.conf
echo "PresharedKey = $(cat /config/auth/peer1.preshared)" >> $out_files_dir/peer1.conf
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )" >> $out_files_dir/peer1.conf
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )" >> $out_files_dir/peer1.conf  # Ext ip
echo "-----"
echo "peer2 config > $out_files_dir/peer2.conf"
echo ""
echo "[Interface]" > $out_files_dir/peer2.conf
echo "PrivateKey = $(cat /config/auth/peer2.private)" >> $out_files_dir/peer2.conf
echo "ListenPort = $( cat /tmp/wg/port_num )" >> $out_files_dir/peer2.conf
echo "Address = $( cat /tmp/wg/peer2_ip )/24" >> $out_files_dir/peer2.conf
echo "DNS = $( cat /tmp/wg/dns )" >> $out_files_dir/peer2.conf
echo "" >> $out_files_dir/peer2.conf
echo "[Peer]" >> $out_files_dir/peer2.conf
echo "PublicKey = $(cat /config/auth/wg0.public)" >> $out_files_dir/peer2.conf
echo "PresharedKey = $(cat /config/auth/peer2.preshared)" >> $out_files_dir/peer2.conf
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )" >> $out_files_dir/peer2.conf
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )" >> $out_files_dir/peer2.conf  # Ext ip
echo "-----"
echo "peer3 config > $out_files_dir/peer3.conf"
echo ""
echo "[Interface]" > $out_files_dir/peer3.conf
echo "PrivateKey = $(cat /config/auth/peer3.private)" >> $out_files_dir/peer3.conf
echo "ListenPort = $( cat /tmp/wg/port_num )" >> $out_files_dir/peer3.conf
echo "Address = $( cat /tmp/wg/peer3_ip )/24" >> $out_files_dir/peer3.conf
echo "DNS = $( cat /tmp/wg/dns )" >> $out_files_dir/peer3.conf
echo "" >> $out_files_dir/peer3.conf
echo "[Peer]" >> $out_files_dir/peer3.conf
echo "PublicKey = $(cat /config/auth/wg0.public)" >> $out_files_dir/peer3.conf
echo "PresharedKey = $(cat /config/auth/peer3.preshared)" >> $out_files_dir/peer3.conf
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )" >> $out_files_dir/peer3.conf
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )" >> $out_files_dir/peer3.conf  # Ext ip

echo "-----"
echo "Done!"
