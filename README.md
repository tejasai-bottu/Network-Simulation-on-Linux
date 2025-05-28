# Network-Simulation-on-Linux

## Introduction

The **Network-Simulation-on-Linux** project simulates a basic computer network environment using Linux **network namespaces** and **virtual Ethernet interfaces**. It allows users to create an isolated networking lab on a single machine—ideal for testing:

- IP routing  
- SSH connectivity  
- Firewall rules (`iptables`)  
- ARP behavior  
- Packet sniffing  
- File transfer via `scp`

### This project is useful for:

- Students and learners of computer networks  
- Cybersecurity and system administrators for safe network testing  
- Practicing real-world networking concepts in a virtual lab  

---

## Project Structure

```bash
Network-Simulation-on-Linux/
├── README.md            # Documentation (this file)
├── setup.sh             # Script to configure virtual network
├── cleanup.sh           # Script to tear down the virtual network
├── auto.sh              # Automates full setup and cleanup
├── demo_logs/           # Directory to store log outputs of commands
├── files/               # Test files for SCP transfer
```

---

## Usage Instructions

### Initial Setup

```bash
cd ~/Downloads/Network-Simulation-on-Linux
chmod +x setup.sh cleanup.sh auto.sh
sudo ./auto.sh
```

### Manual Run (if needed)

```bash
sudo ./setup.sh
# (run tests or inspect network)
sudo ./cleanup.sh
```

---

## Components Description

### `setup.sh`

Core script of the simulation. It:

- Creates **three network namespaces**: `client1`, `client2`, and `router`  
- Links them with **virtual Ethernet pairs**:  
  - `veth-c1` ↔ `veth-r1`  
  - `veth-c2` ↔ `veth-r2`  
- Assigns IP addresses:  
  - `client1`: `192.168.1.2/24` via `192.168.1.1` (router)  
  - `client2`: `192.168.2.2/24` via `192.168.2.1` (router)  
- Enables **IP forwarding** on the router  
- Adds an `iptables` rule to **block ICMP** (ping) from `client2` to `client1`  
- Tests **SSH and SCP** connectivity from `client1` to `client2`  
- Captures logs:  
  - ARP tables  
  - Ping outputs  
  - `tcpdump` packet captures  

### `cleanup.sh`

- Destroys all created namespaces and interfaces  
- Handles missing resources gracefully  
- Ensures the system is clean for the next run  

### `auto.sh`

- Automates:
  - Running `setup.sh`  
  - Waiting 10 seconds  
  - Running `cleanup.sh`  

---

## Functional Overview

### Network Topology

```
client1 -- veth-c1 <-> veth-r1 -- router -- veth-r2 <-> veth-c2 -- client2
```

### Subnets

- `client1`: `192.168.1.2/24` via `192.168.1.1`  
- `client2`: `192.168.2.2/24` via `192.168.2.1`  

### Simulated Functions

- **SSH**: Secure shell from `client1` to `client2` (password prompt bypassed)  
- **SCP**: File transfer using `scp` command  
- **ICMP Blocking**: Ping blocked from `client2` to `client1` using `iptables`  
- **Packet Sniffing**: Capture 10 packets on router’s interface using `tcpdump`  
- **ARP Table View**: Inspect ARP entries on `client1`  

---

## Output and Logs

All outputs are saved in the `demo_logs/` directory:

- `ssh_connection.txt`: SSH success or error logs  
- `scp_log.txt`: File transfer logs  
- `ping_blocked.txt`: Ping result showing dropped ICMP  
- `tcpdump_output.txt`: Captured packets on router  
- `arp_table.txt`: ARP entries from `client1`  

---

## Key Learning Outcomes

- Understanding **Linux namespaces** and virtual networking  
- Routing between isolated LANs using a **virtual router**  
- Using **SSH and SCP** in simulated environments  
- Applying basic **iptables** rules for firewall behavior  
- Using `tcpdump` and `arp` for network diagnostics  

---

## Conclusion

**Network-Simulation-on-Linux** offers a lightweight yet powerful way to simulate real-world networking behavior entirely on a Linux machine. It avoids the need for heavyweight tools like GNS3 or virtual machines and serves as an excellent platform for:

- Learning  
- Testing  
- Experimenting with network behavior in a controlled, reproducible environment  

