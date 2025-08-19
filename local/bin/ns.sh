#!/bin/zsh
emulate -LR zsh # reset zsh options

local ip=192.168.8.4
local ip_wifi=192.168.8.33
local server=192.168.8.3

case $1 in
    2 )
        ip=192.168.1.2
        server=192.168.1.1;;
    3 )
        server=192.168.8.3;;
    8 )
        server=192.168.8.8;;
    9 )
        server=192.168.8.9;;
    11 )
        server=192.168.8.11;;
    12 )
        server=192.168.8.12;;
esac

dns_server=$server
case $1 in
    2 )
        dns_server=192.168.1.1;;
esac

sudo networksetup -setmanual Ethernet $ip 255.255.255.0 $server
sudo networksetup -setdnsservers Ethernet $dns_server

sudo networksetup -setmanual Wi-Fi $ip_wifi 255.255.255.0 $server
sudo networksetup -setdnsservers Wi-Fi $dns_server

echo Gateway of Ethernet\($GREEN$ip$CR\) and Wi-Fi\($GREEN$ip_wifi$CR\) is ${RED}$server${CR}.
echo DNS of Ethernet\($GREEN$ip$CR\) and Wi-Fi\($GREEN$ip_wifi$CR\) is ${RED}$dns_server${CR}.

