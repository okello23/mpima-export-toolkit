#!/usr/bin/env bash
SIMULATE=false
[[ "$1" == "--simulate" ]] && SIMULATE=true

echo "=== STEP 3: Fix PAM for vsftpd ==="

if $SIMULATE; then
    echo "[SIMULATOR] Would overwrite /etc/pam.d/vsftpd"
else
    sudo bash -c 'cat >/etc/pam.d/vsftpd' <<EOF
auth    required        pam_listfile.so item=user sense=deny file=/etc/ftpusers onerr=succeed

@include common-account
@include common-session
@include common-auth
EOF
fi
