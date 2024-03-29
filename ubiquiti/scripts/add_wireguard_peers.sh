#!/bin/vbash

# For Ubiquiti EdgeRouter X

# Setup 
wg genkey | tee /config/auth/peer4.private | wg pubkey > /config/auth/peer4.public
openssl rand -base64 32 > /config/auth/peer4.preshared

wg genkey | tee /config/auth/peer5.private | wg pubkey > /config/auth/peer5.public
openssl rand -base64 32 > /config/auth/peer5.preshared

wg genkey | tee /config/auth/peer6.private | wg pubkey > /config/auth/peer6.public
openssl rand -base64 32 > /config/auth/peer6.preshared

# Session #
# make sure script is run as group vyattacfg
echo "Changing shell..."
if [ $(id -gn) != vyattacfg ]; then
    exec sg vyattacfg "$0 $*"
fi

# vyatta-cfg-cmd-wrapper #
run=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$run begin

echo "Adding peers..."
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer4.public ) endpoint $( cat /tmp/wg/ext_ip ):51820  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer4.public ) allowed-ips $( cat /tmp/wg/peer4_ip )/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer4.public ) preshared-key $( cat /config/auth/peer4.preshared )
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer4.public ) description "$( cat /tmp/wg/peer4_desc )"

$run set interfaces wireguard wg0 peer $( cat /config/auth/peer5.public ) endpoint $( cat /tmp/wg/ext_ip ):51820  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer5.public ) allowed-ips $( cat /tmp/wg/peer5_ip )/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer5.public ) preshared-key $( cat /config/auth/peer5.preshared )
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer5.public ) description "$( cat /tmp/wg/peer5_desc )"

$run set interfaces wireguard wg0 peer $( cat /config/auth/peer6.public ) endpoint $( cat /tmp/wg/ext_ip ):51820  # External IP
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer6.public ) allowed-ips $( cat /tmp/wg/peer6_ip )/32
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer6.public ) preshared-key $( cat /config/auth/peer6.preshared )
$run set interfaces wireguard wg0 peer $( cat /config/auth/peer6.public ) description "$( cat /tmp/wg/peer6_desc )"

echo "Commiting and saving..."
$run commit
$run save
$run end


echo ""
echo ""
echo "--- WG Info ---"
echo "peer4 Private Key:"
cat /config/auth/peer4.private
echo "peer4 Public Key:"
cat /config/auth/peer4.public
echo "peer4 preshared Key:"
cat /config/auth/peer4.preshared
echo ''
echo "peer5 Private Key:"
cat /config/auth/peer5.private
echo "peer5 Public Key:"
cat /config/auth/peer5.public
echo "peer5 preshared Key:"
cat /config/auth/peer5.preshared
echo ''
echo "peer6 Private Key:"
cat /config/auth/peer6.private
echo "peer6 Public Key:"
cat /config/auth/peer6.public
echo "peer6 preshared Key:"
cat /config/auth/peer6.preshared


echo "====="
echo "Creating dir for configs and saving there..."
out_files_dir=/tmp/wg_configs 
mkdir -p $out_files_dir

echo "Saving configs to $out_files_dir..."
echo "-----"

echo "-----"
echo "peer4 ($( cat /tmp/wg/peer4_desc )) config:"
echo ""
echo "[Interface]" > $out_files_dir/peer4.conf
echo "PrivateKey = $(cat /config/auth/peer4.private)" >> $out_files_dir/peer4.conf
echo "ListenPort = $( cat /tmp/wg/port_num )" >> $out_files_dir/peer4.conf
echo "Address = $( cat /tmp/wg/peer4_ip )/24" >> $out_files_dir/peer4.conf
echo "DNS = $( cat /tmp/wg/dns )" >> $out_files_dir/peer4.conf
echo "" >> $out_files_dir/peer4.conf
echo "[Peer]" >> $out_files_dir/peer4.conf
echo "PublicKey = $(cat /config/auth/wg0.public)" >> $out_files_dir/peer4.conf
echo "PresharedKey = $(cat /config/auth/peer4.preshared)" >> $out_files_dir/peer4.conf
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )" >> $out_files_dir/peer4.conf
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )" >> $out_files_dir/peer4.conf

echo "-----"
echo "peer5 ($( cat /tmp/wg/peer5_desc )) config:"
echo ""
echo "[Interface]" > $out_files_dir/peer5.conf
echo "PrivateKey = $(cat /config/auth/peer5.private)" >> $out_files_dir/peer5.conf
echo "ListenPort = $( cat /tmp/wg/port_num )" >> $out_files_dir/peer5.conf
echo "Address = $( cat /tmp/wg/peer5_ip )/24" >> $out_files_dir/peer5.conf
echo "DNS = $( cat /tmp/wg/dns )" >> $out_files_dir/peer5.conf
echo "" >> $out_files_dir/peer5.conf
echo "[Peer]" >> $out_files_dir/peer5.conf
echo "PublicKey = $(cat /config/auth/wg0.public)" >> $out_files_dir/peer5.conf
echo "PresharedKey = $(cat /config/auth/peer5.preshared)" >> $out_files_dir/peer5.conf
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )" >> $out_files_dir/peer5.conf
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )" >> $out_files_dir/peer5.conf

echo "-----"
echo "peer6 ($( cat /tmp/wg/peer6_desc )) config:"
echo ""
echo "[Interface]" > $out_files_dir/peer6.conf
echo "PrivateKey = $(cat /config/auth/peer6.private)" >> $out_files_dir/peer6.conf
echo "ListenPort = $( cat /tmp/wg/port_num )" >> $out_files_dir/peer6.conf
echo "Address = $( cat /tmp/wg/peer6_ip )/24" >> $out_files_dir/peer6.conf
echo "DNS = $( cat /tmp/wg/dns )" >> $out_files_dir/peer6.conf
echo "" >> $out_files_dir/peer6.conf
echo "[Peer]" >> $out_files_dir/peer6.conf
echo "PublicKey = $(cat /config/auth/wg0.public)" >> $out_files_dir/peer6.conf
echo "PresharedKey = $(cat /config/auth/peer6.preshared)" >> $out_files_dir/peer6.conf
echo "AllowedIPs = $( cat /tmp/wg/wg0_ip )/32, $( cat /tmp/wg/local_subnet )" >> $out_files_dir/peer6.conf
echo "Endpoint = $( cat /tmp/wg/ext_ip ):$( cat /tmp/wg/port_num )" >> $out_files_dir/peer6.conf
