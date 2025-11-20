#!/usr/bin/env bash
SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true

echo "=== STEP 5: Finalize and restart vsftpd ==="

if $SIMULATE; then
    echo "[SIMULATOR] Would create /var/log/vsftpd.log and restart vsftpd"
else
    sudo touch /var/log/vsftpd.log
    sudo chown ftp:adm /var/log/vsftpd.log 2>/dev/null || true

    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd
fi

# Ensure user list
if $SIMULATE; then
    echo "[SIMULATOR] Would add mpima to /etc/vsftpd.userlist"
else
    echo "mpima" | sudo tee /etc/vsftpd.userlist >/dev/null
fi

echo "==============================="
echo "Setup complete!"
echo "FTP Server ready on port 2121"
echo "Upload directory: /srv/mpima-export"
echo "User: mpima"
echo ""
echo "Run: sudo passwd mpima  # to set password"
echo "Test: ftp <server-ip> 2121"
