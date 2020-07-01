#!/bin/bash
log_time(){
  current_time=$(/bin/date +"[%x %H:%M:%S:%N]")
  printf "$current_time"
}

echo_time() {
  echo "$(log_time) $*";
}

prepend_log_time() { 
  while read line; do 
    echo "$(log_time) ${line}";
  done; 
}
