#!/usr/bin/env bash
set -euo pipefail

SIMULATE=false
[ "${1:-}" = "--simulate" ] && SIMULATE=true

LOGDIR="../logs"
mkdir -p "${LOGDIR}"
LOGFILE="${LOGDIR}/step2-$(date +%Y%m%d-%H%M%S).log"

echo "STEP 2: Install & configure vsftpd" | tee -a "${LOGFILE}"
echo "SIMULATE=${SIMULATE}" | tee -a "${LOGFILE}"

if ! $SIMULATE; then
  # Fix broken apt repos automatically if apt update errors for NO_PUBKEY / unsigned repo
  echo "Running apt update (and auto-comment broken repos if any)..." | tee -a "${LOGFILE}"
  APT_OUTPUT=$(apt update 2>&1) || APT_OUTPUT="$APT_OUTPUT"$'\n'"$(apt update 2>&1 || true)"
  echo "$APT_OUTPUT" | tee -a "${LOGFILE}"
  if echo "$APT_OUTPUT" | grep -E "NO_PUBKEY|not signed" >/dev/null 2>&1; then
    echo "Detected broken repos; attempting to comment them out..." | tee -a "${LOGFILE}"
    grep -R "bookworm\|apt.envoyproxy.io" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null | awk -F: '{print $1}' | sort -u \
      | while read -r f; do
        echo "Commenting lines in $f" | tee -a "${LOGFILE}"
        sed -i.bak -E 's/^(deb( |-src )?)/# \1/' "$f"
      done
    apt update 2>&1 | tee -a "${LOGFILE}"
  fi
fi

if ! command -v vsftpd >/dev/null 2>&1; then
  if $SIMULATE; then
    echo "SIMULATE: would apt install vsftpd" | tee -a "${LOGFILE}"
  else
    echo "Installing vsftpd..." | tee -a "${LOGFILE}"
    apt install -y vsftpd 2>&1 | tee -a "${LOGFILE}"
  fi
else
  echo "vsftpd already installed" | tee -a "${LOGFILE}"
fi

# Create mpima user if missing
if id mpima >/dev/null 2>&1; then
  echo "User mpima already exists" | tee -a "${LOGFILE}"
else
  if $SIMULATE; then
    echo "SIMULATE: would create user mpima with home /srv/mpima-export" | tee -a "${LOGFILE}"
  else
    echo "Creating user mpima..." | tee -a "${LOGFILE}"
    adduser --home /srv/mpima-export --shell /bin/false --gecos "" --disabled-password mpima
  fi
fi

# Create export directory
if $SIMULATE; then
  echo "SIMULATE: would create /srv/mpima-export and set chown mpima:mpima" | tee -a "${LOGFILE}"
else
  mkdir -p /srv/mpima-export
  chown mpima:mpima /srv/mpima-export
  chmod 755 /srv/mpima-export
  echo "/srv/mpima-export set up" | tee -a "${LOGFILE}"
fi

# Ensure /etc/shells contains /bin/false to avoid pam_shells issues if present
if $SIMULATE; then
  echo "SIMULATE: would ensure /bin/false exists in /etc/shells" | tee -a "${LOGFILE}"
else
  if ! grep -Fxq "/bin/false" /etc/shells 2>/dev/null; then
    echo "/bin/false" >> /etc/shells
    echo "Appended /bin/false to /etc/shells" | tee -a "${LOGFILE}"
  fi
fi

# Ensure PAM for vsftpd is not rejecting shells (safe default)
if $SIMULATE; then
  echo "SIMULATE: would write safe /etc/pam.d/vsftpd" | tee -a "${LOGFILE}"
else
  cat >/etc/pam.d/vsftpd <<'PAMEOF'
# vsftpd PAM config (managed by mpima-export-patcher)
auth    required        pam_listfile.so item=user sense=deny file=/etc/ftpusers onerr=succeed
@include common-account
@include common-session
@include common-auth
PAMEOF
  echo "/etc/pam.d/vsftpd updated" | tee -a "${LOGFILE}"
fi

# Write vsftpd.conf (idempotent)
if $SIMULATE; then
  echo "SIMULATE: would write /etc/vsftpd.conf with mpima settings" | tee -a "${LOGFILE}"
else
  cp /etc/vsftpd.conf /etc/vsftpd.conf.mpima.bak 2>/dev/null || true
  cat >/etc/vsftpd.conf <<'VSF_CONF'
listen=YES
listen_ipv6=NO
listen_port=2121

local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES

chroot_local_user=YES
allow_writeable_chroot=YES

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40050

anonymous_enable=NO

xferlog_enable=YES
xferlog_std_format=YES
log_ftp_protocol=YES
dual_log_enable=YES
vsftpd_log_file=/var/log/vsftpd.log
xferlog_file=/var/log/xferlog

userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO

ftpd_banner=Welcome to mPIMA FTP Server.
VSF_CONF
  echo "/etc/vsftpd.conf written" | tee -a "${LOGFILE}"

  echo "mpima" > /etc/vsftpd.userlist
  echo "/etc/vsftpd.userlist created" | tee -a "${LOGFILE}"
fi

# Ensure log file exists
if $SIMULATE; then
  echo "SIMULATE: would create /var/log/vsftpd.log" | tee -a "${LOGFILE}"
else
  touch /var/log/vsftpd.log
  chown root:adm /var/log/vsftpd.log || true
  chmod 644 /var/log/vsftpd.log
fi

# Restart vsftpd
if $SIMULATE; then
  echo "SIMULATE: would restart vsftpd service" | tee -a "${LOGFILE}"
else
  systemctl restart vsftpd
  systemctl enable vsftpd
  echo "vsftpd restarted and enabled" | tee -a "${LOGFILE}"
fi

# UFW firewall rules (only if active)
if $SIMULATE; then
  echo "SIMULATE: would check ufw and allow ports 2121 and 40000:40050" | tee -a "${LOGFILE}"
else
  if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    ufw allow 2121/tcp
    ufw allow 40000:40050/tcp
    echo "UFW rules applied" | tee -a "${LOGFILE}"
  else
    echo "UFW not active or not installed — skipping firewall changes" | tee -a "${LOGFILE}"
  fi
fi

echo "STEP 2 completed." | tee -a "${LOGFILE}"
