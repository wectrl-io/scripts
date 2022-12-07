target_ip=$1
target_script=$2
create_wg_interface=$3
user=$4

if [ -z "$target_ip" ] ; then
  echo "No IP address provided (first argument)"
  issue=1
fi

if [ -z "$target_script" ] ; then
  echo "No script provided (second argument)"
  issue=1
fi

if [ -z "$create_wg_interface" ] ; then
  echo "No wg boolean provided (to add wg interface or not) (third argument)"
elif [ 1 -eq $create_wg_interface ] ; then
  echo "Will create intrface wg0."
fi

if [ ! -z "$issue" ] ; then
  exit
fi

echo "Connecting to:    $target_ip"
echo "Executing script: $target_script"

if [ -z "$user" ]; then
  read -p "Username (for $target_ip): " user
else
  echo "User: $user"
fi

read -s -p "Password ($user@$target_ip): " password
echo ""

# Make sure wg dir is created
sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "mkdir /tmp/wg"

if [ 1 -eq $create_wg_interface ]; then
    read -p 'External IP: ' ext_ip
    # echo $ext_ip > /tmp/wg/ext_ip
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $ext_ip > /tmp/wg/ext_ip"

    read -p 'Port to use (ex: 51820): ' port_num
    # echo $port_num > /tmp/wg/port_num
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $port_num > /tmp/wg/port_num"

    read -p 'Local Subnet (ex: 10.1.1.0/24): ' local_subnet
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $local_subnet > /tmp/wg/local_subnet" # Subnet That we want to access

    read -p 'WG0 IP (ex: 10.0.1.1): ' wg0_ip
    # echo $wg0_ip > /tmp/wg/wg0_ip  # "10.0.1.1"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $wg0_ip > /tmp/wg/wg0_ip"

    # TODO: CHECK for already created peers
    read -p 'peer1 IP (ex: 10.0.1.11): ' peer1_ip
    # echo $peer1_ip > /tmp/wg/peer1_ip  # "10.0.1.11"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer1_ip > /tmp/wg/peer1_ip"

    read -p 'peer1 Description (ex: "Peer 1"): ' peer1_desc
    # echo $peer1_desc > /tmp/wg/peer1_desc  # "Peer 1"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer1_desc > /tmp/wg/peer1_desc"


    read -p 'peer2 IP (ex: 10.0.1.12): ' peer2_ip
    # echo $peer2_ip > /tmp/wg/peer2_ip  # "10.0.1.12"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer2_ip > /tmp/wg/peer2_ip"

    read -p 'peer2 Description (ex: "Peer 2"): ' peer2_desc
    # echo $peer2_desc > /tmp/wg/peer2_desc  # "Peer 2"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer2_desc > /tmp/wg/peer2_desc"

    read -p 'peer3 IP (ex: 10.0.1.13): ' peer3_ip
    # echo $peer3_ip > /tmp/wg/peer3_ip  # "10.0.1.13"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer3_ip > /tmp/wg/peer3_ip"

    read -p 'peer3 Description (ex: "Peer 3"): ' peer3_desc
    # echo $peer3_desc > /tmp/wg/peer3_desc  # "Peer 3"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer3_desc > /tmp/wg/peer3_desc"
  
  else
    # TODO: CHECK for already created peers
    read -p 'peer4 IP (ex: 10.0.1.14): ' peer4_ip
    # echo $peer4_ip > /tmp/wg/peer4_ip  # "10.0.1.14"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer4_ip > /tmp/wg/peer4_ip"

    read -p 'peer4 Description (ex: "Peer 4"): ' peer4_desc
    # echo $peer4_desc > /tmp/wg/peer4_desc  # "Peer 1"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer4_desc > /tmp/wg/peer4_desc"


    read -p 'peer5 IP (ex: 10.0.1.15): ' peer5_ip
    # echo $peer5_ip > /tmp/wg/peer5_ip  # "10.0.1.15"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer5_ip > /tmp/wg/peer5_ip"

    read -p 'peer5 Description (ex: "Peer 5"): ' peer5_desc
    # echo $peer5_desc > /tmp/wg/peer5_desc  # "Peer 5"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer5_desc > /tmp/wg/peer5_desc"

    read -p 'peer6 IP (ex: 10.0.1.16): ' peer6_ip
    # echo $peer6_ip > /tmp/wg/peer6_ip  # "10.0.1.16"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer6_ip > /tmp/wg/peer6_ip"

    read -p 'peer6 Description (ex: "Peer 6"): ' peer6_desc
    # echo $peer6_desc > /tmp/wg/peer6_desc  # "Peer 3"
    sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer6_desc > /tmp/wg/peer6_desc"
fi

read -p 'DNS (ex: 10.1.1.1, 1.1.1.1): ' dns
# echo $dns > /tmp/wg/dns
sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $dns > /tmp/wg/dns"

echo "Prep done! Executing script ($script) on target."
sshpass -p $password ssh -o "StrictHostKeyChecking no" -t ubnt@$target_ip "/bin/vbash -s" < $target_script
