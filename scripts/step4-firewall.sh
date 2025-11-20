#!/usr/bin/env bash
SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true

echo "=== STEP 4: Firewall configuration ==="

# Check if UFW is active
if sudo ufw status | grep -q "Status: active"; then
    echo "UFW is active — applying rules..."
    if $SIMULATE; then
        echo "[SIMULATOR] Would allow FTP port 2121/tcp and passive range 40000-40050/tcp"
    else
        sudo ufw allow 2121/tcp
        sudo ufw allow 40000:40050/tcp
    fi
else
    echo "UFW is not active — skipping firewall configuration."
fi
