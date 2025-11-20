#!/usr/bin/env bash
SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true
[[ "$1" == "-n" ]] && SIMULATE=true

echo "=== STEP 5: Finalize and restart vsftpd ==="

if ! dpkg -l | grep -q vsftpd; then
    echo "⚠ vsftpd is not installed. Skipping service restart/enable."
    exit 1
fi

if $SIMULATE; then
    echo "[SIMULATOR] Would touch /var/log/vsftpd.log and restart service"
else
    sudo touch /var/log/vsftpd.log
    sudo chown ftp:adm /var/log/vsftpd.log 2>/dev/null || true
    sudo systemctl daemon-reload
    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd
fi

echo "=== Setup complete! ==="
echo "FTP ready at port 2121, upload dir: /srv/mpima-export"
