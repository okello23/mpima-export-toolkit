#!/usr/bin/env bash
SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true

echo "=== STEP 2: Installing vsftpd ==="

# Ensure universe repository is enabled (required for vsftpd on Ubuntu 16.04)
echo "Checking if universe repository is enabled..."
if $SIMULATE; then
    echo "[SIMULATOR] Would enable universe repository and update apt"
else
    sudo add-apt-repository universe -y
    sudo apt update
fi

# Install vsftpd
echo "Installing vsftpd package..."
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

# Ensure mpima directory exists and has correct permissions
if $SIMULATE; then
    echo "[SIMULATOR] Would create /srv/mpima-export and set ownership"
else
    sudo mkdir -p /srv/mpima-export
    sudo chown mpima:mpima /srv/mpima-export
    sudo chmod 755 /srv/mpima-export
fi

echo "STEP 2 completed."
