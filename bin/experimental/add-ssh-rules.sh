#!/bin/bash
script_path="$( cd "$(/usr/bin/dirname "$0")" >/dev/null 2>&1 ; /bin/pwd -P )"
path_to_utils=${script_path}/utils.sh

. ${path_to_utils} --source-only 

# set_rules [name] [iptables rules]
function set_rules(){
  if /usr/sbin/iptables -C ${2}; then
    echo_time "${1} rule exist"
  else
    echo_time "No ${1} rule exist"
    echo_time "Applying ${1} rule"
    /usr/sbin/iptables -I ${2}  
  fi
}

server_if="eth0"
server_ip="192.168.2.1"
client_net="192.168.2.0/24"


# Allow node-red access from all port
ssh_if=${server_if}
set_rules "[INPUT][ACCEPT] SSH" "INPUT -i ${ssh_if} -p tcp --dport 22 -d ${server_ip} -s ${client_net}  -j ACCEPT"
set_rules "[OUTPUT][ACCEPT] SSH" "OUTPUT -o ${ssh_if} -p tcp --sport 22 -s ${server_ip} -d ${client_net} -j ACCEPT"

# Allow node-red access from all port. restrict this to only eth0
nodered_if=${server_if}
set_rules "[INPUT][ACCEPT] node-red" "INPUT -i ${nodered_if} -p tcp --dport 1880 -d ${server_ip} -s ${client_net} -j ACCEPT"
set_rules "[OUTPUT][ACCEPT] node-red" "OUTPUT -o ${nodered_if} -p tcp --sport 1880 -s ${server_ip} -d ${client_net} -j ACCEPT"

# Allow DHCP request from eth0 only. Cannot restrict this to 192.168.2.1 since DHCP request might send to broadcast IP
dhcp_if=${server_if}
set_rules "[INPUT][ACCEPT] DHCP" "INPUT -i ${dhcp_if} -p udp --dport 67:68 --sport 67:68 -j ACCEPT"
set_rules "[OUTPUT][ACCEPT] DHCP" "OUTPUT -o ${dhcp_if} -p udp --dport 67:68 --sport 67:68 -j ACCEPT"


# Allow DNS query.  restrict this to eth0 only 
dns_if=${server_if}
set_rules "[INPUT][ACCEPT][UDP] DNS" "INPUT -i ${dns_if} -p udp -m udp --dport 53 -d ${server_ip} -s ${client_net} -j ACCEPT"
set_rules "[INPUT][ACCEPT][TCP] DNS" "INPUT -i ${dns_if} -p tcp -m tcp --dport 53 -d ${server_ip} -s ${client_net} -j ACCEPT"
set_rules "[OUTPUT][ACCEPT][UDP] DNS" "OUTPUT -o ${dns_if} -p udp -m udp --sport 53 -s ${server_ip} -d ${client_net} -j ACCEPT"
set_rules "[OUTPUT][ACCEPT][TCP] DNS" "OUTPUT -o ${dns_if} -p tcp -m tcp --sport 53 -s ${server_ip} -d ${client_net} -j ACCEPT"
# Drop any external dns server
set_rules "[OUTPUT][DROP][UDP] External DNS" "FORWARD -i ${dns_if} -p udp --dport 53 -j DROP"
set_rules "[OUTPUT][DROP][TCP] External DNS" "FORWARD -i ${dns_if} -p tcp --dport 53 -j DROP"

# Allow HTTP port for nginx-nodered dashboard reverse proxy
nginx_if=${server_if}
set_rules "[INPUT][ACCEPT] nginx" "INPUT -i ${nginx_if} -p tcp --dport 80 -d ${server_ip} -s ${client_net} -j ACCEPT"
set_rules "[OUTPUT][ACCEPT] nginx" "OUTPUT -o ${nginx_if} -p tcp --sport 80 -s ${server_ip} -d ${client_net} -j ACCEPT"

