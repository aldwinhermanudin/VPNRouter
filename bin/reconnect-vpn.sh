#!/bin/bash

script_path="$( cd "$(/usr/bin/dirname "$0")" >/dev/null 2>&1 ; /bin/pwd -P )"
path_to_utils=${script_path}/utils.sh
path_to_last_connection_type=${script_path}/config/last_connection_type.elytra
path_to_reconnect_time=${script_path}/config/reconnect_time.elytra
. ${path_to_utils} --source-only 

vpn_connection=$(cat ${path_to_last_connection_type})

# if you change this, also change the timing in crontab. currently this code is run @hourly 
# this will be read by nodered
add_time=$((3600*1000))

echo_time "Reconnect to ${vpn_connection}"

# this will be handled by vpnrouter.service
/sbin/runuser -l  lux -c "/usr/bin/nordvpn connect ${vpn_connection}"
printf $((($(date +%s%N)/1000000)+${add_time})) > ${path_to_reconnect_time}

# this will be handled by vpnrouter.service
bash ${script_path}/add-acl-rules.sh

