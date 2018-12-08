sudo iptables -I OUTPUT -s 192.168.10.1 -d 192.168.10.2 -j DROP
sudo iptables -I OUTPUT -s 192.168.10.2 -d 192.168.10.1 -j DROP