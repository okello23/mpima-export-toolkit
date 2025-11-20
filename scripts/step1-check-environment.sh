#!/usr/bin/env bash
set -euo pipefail

SIMULATE=false
[ "${1:-}" = "--simulate" ] && SIMULATE=true

LOGDIR="../logs"
mkdir -p "${LOGDIR}"
LOGFILE="${LOGDIR}/step1-$(date +%Y%m%d-%H%M%S).log"

echo "STEP 1: Environment check" | tee -a "${LOGFILE}"
echo "Date: $(date -u)" | tee -a "${LOGFILE}"

echo "Checking OS..." | tee -a "${LOGFILE}"
if command -v lsb_release >/dev/null 2>&1; then
  lsb_release -a 2>/dev/null | tee -a "${LOGFILE}"
else
  uname -a | tee -a "${LOGFILE}"
fi

echo "Checking user (must be root)..." | tee -a "${LOGFILE}"
echo "UID=$(id -u)   USER=$(id -un)" | tee -a "${LOGFILE}"
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: Must run as root (sudo)." | tee -a "${LOGFILE}"
  exit 1
fi

echo "Checking network interfaces..." | tee -a "${LOGFILE}"
ip -c addr | tee -a "${LOGFILE}"

echo "Checking existing vsftpd installation..." | tee -a "${LOGFILE}"
if command -v vsftpd >/dev/null 2>&1; then
  vsftpd -v 2>&1 | head -n1 | tee -a "${LOGFILE}"
else
  echo "vsftpd: NOT INSTALLED" | tee -a "${LOGFILE}"
fi

echo "Checking UFW status..." | tee -a "${LOGFILE}"
if command -v ufw >/dev/null 2>&1; then
  ufw status verbose 2>&1 | tee -a "${LOGFILE}"
else
  echo "ufw: not present" | tee -a "${LOGFILE}"
fi

echo "Checking mpima user..." | tee -a "${LOGFILE}"
if id mpima >/dev/null 2>&1; then
  getent passwd mpima | tee -a "${LOGFILE}"
else
  echo "User mpima: NOT PRESENT" | tee -a "${LOGFILE}"
fi

echo "STEP 1 completed." | tee -a "${LOGFILE}"
$SIMULATE && echo "SIMULATION: No changes made in Step 1." | tee -a "${LOGFILE}"
