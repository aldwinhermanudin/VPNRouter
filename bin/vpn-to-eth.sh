#!/bin/bash

# Share Wifi with Eth device
#
#
# This script is created to work with Raspbian Stretch
# but it can be used with most of the distributions
# by making few changes.
#
# Make sure you have already installed `dnsmasq`
# Please modify the variables according to your need
# Don't forget to change the name of network interface
# Check them with `ifconfig`

script_path="$( cd "$(/usr/bin/dirname "$0")" >/dev/null 2>&1 ; /bin/pwd -P )"
path_to_utils=${script_path}/utils.sh
path_to_last_connection_type=${script_path}/config/last_connection_type.elytra
path_to_nordvpn_connect=${script_path}/nordvpn-connect.sh

. ${path_to_utils} --source-only 

# after changing to systemd instead of crontab this is not needed
#sleep 120

echo_time "Setting up VPN to Ethernet Route"

ip_address="192.168.2.1"
netmask="255.255.255.0"
eth="eth0"
dest="tun0"
vpn_connection=$(cat ${path_to_last_connection_type})

sudo ifconfig $eth down
sleep 10
sudo ifconfig $eth up

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -o $dest -j MASQUERADE
sudo iptables -A FORWARD -i $dest -o $eth -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $eth -o $dest -j ACCEPT

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo ifconfig $eth $ip_address netmask $netmask

# Remove default route created by dhcpcd
sudo ip route del 0/0 dev $eth &> /dev/null

sudo systemctl stop dnsmasq

sudo systemctl start dnsmasq

sleep 20

# this is preferable but for some reason does not work 
#cmd=(${path_to_nordvpn_connect} ${vpn_connection})
#${cmd[@]}
#echo_time "Running ${path_to_nordvpn_connect} ${vpn_connection}"
#/sbin/runuser -l  lux -c '${path_to_nordvpn_connect} ${vpn_connection}'

echo_time "Connecting to ${vpn_connection}"
/sbin/runuser -l  lux -c "/usr/bin/nordvpn connect ${vpn_connection}"

bash ${script_path}/add-acl-rules.sh

