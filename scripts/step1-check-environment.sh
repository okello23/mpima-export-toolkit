#!/usr/bin/env bash
SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true

echo "=== STEP 1: Environment check ==="

echo "Checking OS..."
lsb_release -a || echo "[WARN] lsb_release not found"

echo "Checking user..."
id

echo "Checking network interfaces..."
ip addr

echo "Checking existing vsftpd installation..."
if command -v vsftpd &>/dev/null; then
    vsftpd -version || true
else
    echo "vsftpd not installed"
fi

echo "STEP 1 completed."
