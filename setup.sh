#!/bin/bash
# setup.sh - Sets up virtual network namespaces and simulates routing, SSH, DNS, DHCP, etc.

set -eX

echo "[+] Creating namespaces..."
ip netns add client1 && echo "Created namespace: client1"
ip netns add client2 && echo "Created namespace: client2"
ip netns add router && echo "Created namespace: router"

echo "[+] Creating veth pairs..."
ip link add veth-c1 type veth peer name veth-r1 && echo "Created veth pair: veth-c1 <-> veth-r1"
ip link add veth-c2 type veth peer name veth-r2 && echo "Created veth pair: veth-c2 <-> veth-r2"

echo "[+] Assigning veth to namespaces..."
ip link set veth-c1 netns client1 && echo "Moved veth-c1 to client1"
ip link set veth-r1 netns router && echo "Moved veth-r1 to router"
ip link set veth-c2 netns client2 && echo "Moved veth-c2 to client2"
ip link set veth-r2 netns router && echo "Moved veth-r2 to router"

echo "[+] Configuring IP addresses..."
ip netns exec client1 ip addr add 192.168.1.2/24 dev veth-c1 && echo "Assigned 192.168.1.2 to veth-c1 in client1"
ip netns exec client2 ip addr add 192.168.2.2/24 dev veth-c2 && echo "Assigned 192.168.2.2 to veth-c2 in client2"
ip netns exec router ip addr add 192.168.1.1/24 dev veth-r1 && echo "Assigned 192.168.1.1 to veth-r1 in router"
ip netns exec router ip addr add 192.168.2.1/24 dev veth-r2 && echo "Assigned 192.168.2.1 to veth-r2 in router"

echo "[+] Bringing interfaces up..."
ip netns exec client1 ip link set veth-c1 up && echo "Interface veth-c1 up in client1"
ip netns exec client2 ip link set veth-c2 up && echo "Interface veth-c2 up in client2"
ip netns exec router ip link set veth-r1 up && echo "Interface veth-r1 up in router"
ip netns exec router ip link set veth-r2 up && echo "Interface veth-r2 up in router"

ip netns exec client1 ip link set lo up && echo "Loopback interface up in client1"
ip netns exec client2 ip link set lo up && echo "Loopback interface up in client2"
ip netns exec router ip link set lo up && echo "Loopback interface up in router"

echo "[+] Setting up default routes..."
ip netns exec client1 ip route add default via 192.168.1.1 && echo "Default route via 192.168.1.1 added in client1"
ip netns exec client2 ip route add default via 192.168.2.1 && echo "Default route via 192.168.2.1 added in client2"

echo "[+] Enabling IP forwarding on router..."
ip netns exec router sysctl -w net.ipv4.ip_forward=1 && echo "IP forwarding enabled on router"

echo "[+] Applying iptables rule to block ICMP from client2 to client1..."
ip netns exec router iptables -A FORWARD -s 192.168.2.2 -d 192.168.1.2 -p icmp -j DROP && echo "ICMP from client2 to client1 blocked on router"

echo "[*] Testing SSH connection from client1 to client2..."
# Run ssh with options to avoid prompts and capture all output
ip netns exec client1 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes user@192.168.2.2 echo "Hello SSH" 2>&1 | tee demo_logs/ssh_connection.txt


echo "[*] Transferring file from client1 to client2 using SCP..."
ip netns exec client1 scp /files/test.txt user@192.168.2.2:/tmp |& tee demo_logs/scp_log.txt

echo "[*] Pinging client1 from client2 (should be blocked by iptables)..."
ip netns exec client2 ping -c 3 192.168.1.2 |& tee demo_logs/ping_blocked.txt

echo "[*] Capturing packets on router interface veth-r1..."
ip netns exec router tcpdump -i veth-r1 -c 10 | tee demo_logs/tcpdump_output.txt

echo "[*] Showing ARP table on client1..."
ip netns exec client1 arp -n | tee demo_logs/arp_table.txt


echo "[+] Setup complete!"  