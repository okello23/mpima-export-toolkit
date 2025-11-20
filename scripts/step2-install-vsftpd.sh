#!/usr/bin/env bash
SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true

echo "=== STEP 2: Installing vsftpd ==="
if $SIMULATE; then
    echo "[SIMULATOR] Would run: sudo apt update && sudo apt install -y vsftpd"
else
    sudo apt update
    sudo apt install -y vsftpd
fi

# Create mpima user and folder if not exists
if id mpima &>/dev/null; then
    echo "User mpima exists, skipping creation"
else
    if $SIMULATE; then
        echo "[SIMULATOR] Would create user: mpima"
    else
        sudo adduser --home /srv/mpima-export --shell /bin/false --gecos "" --disabled-password mpima
    fi
fi

# Folder permissions
if $SIMULATE; then
    echo "[SIMULATOR] Would create /srv/mpima-export and set ownership"
else
    sudo mkdir -p /srv/mpima-export
    sudo chown mpima:mpima /srv/mpima-export
    sudo chmod 755 /srv/mpima-export
fi
