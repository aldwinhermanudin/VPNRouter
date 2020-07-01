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


ip_address="192.168.2.1"
netmask="255.255.255.0"
eth="eth0"
wlan="tun0"

sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -o $wlan -j MASQUERADE
sudo iptables -A FORWARD -i $wlan -o $eth -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $eth -o $wlan -j ACCEPT

sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT


sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

