#!/usr/bin/env bash
set -euo pipefail

SIMULATE=false
[ "${1:-}" = "--simulate" ] && SIMULATE=true

LOGDIR="../logs"
mkdir -p "${LOGDIR}"
LOGFILE="${LOGDIR}/step4-$(date +%Y%m%d-%H%M%S).log"

echo "STEP 4: Diagnostics & report" | tee -a "${LOGFILE}"

echo "Gathering vsftpd service status..." | tee -a "${LOGFILE}"
if $SIMULATE; then
  echo "SIMULATE: systemctl status vsftpd" | tee -a "${LOGFILE}"
else
  systemctl status vsftpd --no-pager | tee -a "${LOGFILE}"
fi

echo "Tail last 50 lines of syslog for vsftpd entries (if present)..." | tee -a "${LOGFILE}"
if $SIMULATE; then
  echo "SIMULATE: tail syslog" | tee -a "${LOGFILE}"
else
  if [ -f /var/log/vsftpd.log ]; then
    echo "vsftpd.log exists; tailing:" | tee -a "${LOGFILE}"
    tail -n 50 /var/log/vsftpd.log | tee -a "${LOGFILE}"
  else
    journalctl -u vsftpd -n 50 --no-pager | tee -a "${LOGFILE}" || true
    tail -n 200 /var/log/syslog | grep -i vsftpd | tail -n 50 | tee -a "${LOGFILE}" || true
  fi
fi

echo "Listing /srv/mpima-export contents & permissions..." | tee -a "${LOGFILE}"
ls -la /srv/mpima-export | tee -a "${LOGFILE}"

echo ""
echo "Diagnostics completed. Logs in ${LOGDIR}" | tee -a "${LOGFILE}"
