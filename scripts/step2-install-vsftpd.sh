#!/usr/bin/env bash
# Step 2: Install vsftpd (with support for custom sources.list)
# Works on Ubuntu 16.04 → 20.04 [not tested on later ubuntu versions]
# Supports simulator mode: --simulate or -n

SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true
[[ "$1" == "-n" ]] && SIMULATE=true

echo "=== STEP 2: Installing vsftpd ==="

# Ensure universe repo is enabled
if $SIMULATE; then
    echo "[SIMULATOR] Would check/enable universe repository"
else
    echo "Checking universe repository..."
    sudo add-apt-repository universe -y || true
    sudo apt update
fi

# Check if vsftpd is available
if ! apt-cache policy vsftpd | grep -q Candidate; then
    echo "⚠ vsftpd not found in current repos!"
    if $SIMULATE; then
        echo "[SIMULATOR] Would add temporary official Ubuntu universe repo"
    else
        TEMP_REPO="/etc/apt/sources.list.d/temp-focal-universe.list"
        echo "Adding temporary official Ubuntu universe repo for vsftpd..."
        echo "deb http://archive.ubuntu.com/ubuntu focal universe" | sudo tee "$TEMP_REPO"
        sudo apt update
    fi
fi

# Install vsftpd
if $SIMULATE; then
    echo "[SIMULATOR] Would run: sudo apt install -y vsftpd"
else
    sudo apt install -y vsftpd
fi

# Create mpima user if not exists
if id mpima &>/dev/null; then
    echo "User mpima exists — skipping creation"
else
    if $SIMULATE; then
        echo "[SIMULATOR] Would create user: mpima"
    else
        sudo adduser --home /srv/mpima-export --shell /bin/false --gecos "" --disabled-password mpima
    fi
fi

# Ensure mpima directory exists with correct permissions
if $SIMULATE; then
    echo "[SIMULATOR] Would create /srv/mpima-export and set ownership"
else
    sudo mkdir -p /srv/mpima-export
    sudo chown mpima:mpima /srv/mpima-export
    sudo chmod 755 /srv/mpima-export
fi

echo "STEP 2 completed."

# Optional: Remove temporary repo if added
if [ -f "/etc/apt/sources.list.d/temp-focal-universe.list" ] && ! $SIMULATE; then
    echo "Cleaning up temporary repo..."
    sudo rm -f /etc/apt/sources.list.d/temp-focal-universe.list
    sudo apt update
fi
