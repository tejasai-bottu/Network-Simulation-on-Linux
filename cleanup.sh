#!/bin/bash
# cleanup.sh - Removes all namespaces, veth pairs, and resets system

set -e

echo "[*] Deleting namespaces..."
ip netns del client1 2>/dev/null || echo "client1 not found"
ip netns del client2 2>/dev/null || echo "client2 not found"
ip netns del router 2>/dev/null || echo "router not found"

echo "[*] Deleting leftover veth interfaces..."
ip link del veth-c1 2>/dev/null || true
ip link del veth-c2 2>/dev/null || true
ip link del veth-r1 2>/dev/null || true
ip link del veth-r2 2>/dev/null || true

echo "[*] Cleanup complete!"
