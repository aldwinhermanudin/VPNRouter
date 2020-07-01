#!/bin/bash

script_path="$( cd "$(/usr/bin/dirname "$0")" >/dev/null 2>&1 ; /bin/pwd -P )"
path_to_utils=${script_path}/utils.sh
. ${path_to_utils} --source-only 

ret=0
if /usr/bin/nordvpn connect $1; then 
  echo "Connect $1 succeeded"
  ret=0
else
  echo "Connect $1 failed"
  ret=1
fi

sudo bash ${script_path}/add-acl-rules.sh
exit ${ret}
