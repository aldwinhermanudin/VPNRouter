node-red-dashboard is reverse-proxied by nginx on port 80

# crontab
this porject uses root's crontab to start necessary services
- `@reboot ifconfig eth0 down` is for disabling eth0 at startup. there's a bug in beagleboneblack where wlan0 won't connect if there's a ethernet cable plugged to eth0
- `@reboot nohup /opt/lux/vpn-to-eth.sh >> /media/sdcard0/logs/vpn-to-eth.log 2>&1` this is to 
  - fix eth0 bug that's mention above
  - update iptables to allow IP forward to tun0
  - set eth0 static IPv4
  - restart dnsmasq
  - connect to VPN
  - add necessary rules to iptables for SSH, DHCP, DNS, nginx http, node-red
- `*/5 * * * * nohup /opt/lux/add-ssh-rules.sh >> /media/sdcard0/logs/add-ssh-rules.log 2>&1` every 5 minute check iptables rules. make sure it always allow SSH, DHCPP, DNS, nginx http, node-red

# to-do
- [ ] change password for node-red
- [x] restrict SSH and node-red  acceess to eth0
- [x] dnsmasq to local is not properly configured
- [ ] maybe improve on the dnsmasq configuration?
- [x] block any dns request that is not for 192.168.2.1 on eth0
- [ ] create a topology of the network and which ports is blocked and when its blocked (e.g. nordvpn block all local connection when connected)
- [x] create a connection reseter using crontab

# notes
- very good tutorial for iptables beginner. https://www.howtogeek.com/177621/the-beginners-guide-to-iptables-the-linux-firewall/
- keep debian user with it's password for backup
- .local is for mDNS, do not use this on the dnsmasq configuration
- good question around dnsmasq. https://serverfault.com/questions/250524/dnsmasq-resolves-local-hostname-to-127-0-0-1-all-over-the-net
- good explanation in dnsmasq configuration
- allow node-red run specific command wih sudo power and without password
  1) add files/node-red.sudoers to /etc/sudoers.d
```
#==========[ NAMESERVER ]==========#

# Cache size
cache-size=4096
# Don't read /etc/hosts
no-hosts
# Read additional hosts-file (not only /etc/hosts) to add entries into DNS
addn-hosts=/etc/hosts-dnsmasq
# Auto-append <domain> to simple entries in hosts-file
expand-hosts

#=== HOSTNAME OVERRIDES
address=/localhost/127.0.0.1 # *.localhost => 127.0.0.1

#==========[ DHCP ]==========#
# Enable for the local network?
dhcp-authoritative
# Tell MS Windows to release a lease on shutdown
dhcp-option=vendor:MSFT,2,1i

#=== DHCP
# Domain name
domain=lan
# DNS-resolve hosts in these domains ONLY from /etc/hosts && DHCP leases
local=/lan/

# DHCP range & lease time
dhcp-range=192.168.1.70,192.168.1.89,24h 
# Default route
dhcp-option=3,192.168.1.1

#=== FIXED LEASES
# LAN MY HOSTS
dhcp-host=00:23:54:5d:27:fa,                    rtfm.lan,               192.168.1.2
dhcp-host=00:23:54:5d:27:fb,                    rtfm.lan,               192.168.1.2
dhcp-host=c8:0a:a9:45:f1:03, 00:1e:64:9e:e9:5e, wtf.lan,                192.168.1.3 
```
- good tutorials on dnsmasq https://www.linux.com/topic/networking/advanced-dnsmasq-tips-and-tricks/
