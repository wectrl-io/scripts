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

# if [ 1 -eq $create_wg_interface ]
#   then
#     exit
#     read -p 'External IP: ' ext_ip
#     echo $ext_ip > /tmp/wg/ext_ip
#     sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $ext_ip > /tmp/wg/ext_ip"

#     read -p 'Port to use (ex: 51820): ' port_num
#     # echo $port_num > /tmp/wg/port_num
#     sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $port_num > /tmp/wg/port_num"


#     read -p 'WG0 IP (ex: 10.0.1.1): ' wg0_ip
#     # echo $wg0_ip > /tmp/wg/wg0_ip  # "10.0.1.1"
#     sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $wg0_ip > /tmp/wg/wg0_ip"
# fi

# read -p 'DNS (ex: 10.1.1.1, 1.1.1.1): ' dns
# # echo $dns > /tmp/wg/dns
# sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $dns > /tmp/wg/dns"

# read -p 'peer4 IP (ex: 10.0.1.5): ' peer4_ip
# # echo $peer4_ip > /tmp/wg/peer4_ip  # "10.0.1.2"
# sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer4_ip > /tmp/wg/peer4_ip"

# read -p 'peer4 Description (ex: "Peer 4"): ' peer4_desc
# # echo $peer4_desc > /tmp/wg/peer4_desc  # "Peer 4"
# sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer4_desc > /tmp/wg/peer4_desc"


# read -p 'peer5 IP (ex: 10.0.1.6): ' peer5_ip
# # echo $peer5_ip > /tmp/wg/peer5_ip  # "10.0.1.3"
# sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer5_ip > /tmp/wg/peer5_ip"

# read -p 'peer5 Description (ex: "Peer 5"): ' peer5_desc
# # echo $peer5_desc > /tmp/wg/peer5_desc  # "Peer 5"
# sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer5_desc > /tmp/wg/peer5_desc"

# read -p 'peer6 IP (ex: 10.0.1.7): ' peer6_ip
# # echo $peer6_ip > /tmp/wg/peer6_ip  # "10.0.1.4"
# sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer6_ip > /tmp/wg/peer6_ip"

# read -p 'peer6 Description (ex: "Peer 6"): ' peer6_desc
# # echo $peer6_desc > /tmp/wg/peer6_desc  # "Peer 6"
# sshpass -p $password ssh -o "StrictHostKeyChecking no" ubnt@$target_ip "echo $peer6_desc > /tmp/wg/peer6_desc"

echo "Prep done! Executing script ($script) on target."
sshpass -p $password ssh -o "StrictHostKeyChecking no" -t ubnt@$target_ip "/bin/vbash -s" < $target_script
