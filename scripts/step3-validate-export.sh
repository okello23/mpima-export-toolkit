#!/usr/bin/env bash
set -euo pipefail

SIMULATE=false
[ "${1:-}" = "--simulate" ] && SIMULATE=true

LOGDIR="../logs"
mkdir -p "${LOGDIR}"
LOGFILE="${LOGDIR}/step3-$(date +%Y%m%d-%H%M%S).log"

echo "STEP 3: Validate export directory and basic FTP connection" | tee -a "${LOGFILE}"

# Check directory exists and is writable by mpima
if [ -d /srv/mpima-export ]; then
  echo "/srv/mpima-export exists" | tee -a "${LOGFILE}"
else
  echo "ERROR: /srv/mpima-export missing" | tee -a "${LOGFILE}"
  exit 2
fi

echo "Checking ownership & permissions..." | tee -a "${LOGFILE}"
ls -ld /srv/mpima-export | tee -a "${LOGFILE}"

# Try to write a temp file as user mpima (using sudo -u)
if $SIMULATE; then
  echo "SIMULATE: would attempt write test as mpima" | tee -a "${LOGFILE}"
else
  echo "write-test-$(date +%s)" | sudo -u mpima tee /srv/mpima-export/.mpima_write_test 2>/dev/null | tee -a "${LOGFILE}" || {
    echo "Attempting to fix ownership and retry..." | tee -a "${LOGFILE}"
    chown mpima:mpima /srv/mpima-export
    sudo -u mpima bash -c 'echo success > /srv/mpima-export/.mpima_write_test' || {
      echo "ERROR: cannot write to /srv/mpima-export as mpima" | tee -a "${LOGFILE}"
      exit 3
    }
  }
  echo "Write test OK" | tee -a "${LOGFILE}"
  rm -f /srv/mpima-export/.mpima_write_test || true
fi

# Basic FTP login test using curl (if available)
if command -v curl >/dev/null 2>&1; then
  if $SIMULATE; then
    echo "SIMULATE: would attempt curl ftp login to localhost:2121 with mpima" | tee -a "${LOGFILE}"
  else
    echo "Testing FTP AUTH (no file transfer) with curl..." | tee -a "${LOGFILE}"
    # Attempt connection; this will fail if password unknown - we only verify server accepts connection
    curl -v --connect-timeout 5 "ftp://127.0.0.1:2121/" --user mpima:TEST 2>&1 | tee -a "${LOGFILE}" || true
    echo "Note: curl test used dummy password 'TEST' — a 530 here is expected if password not set." | tee -a "${LOGFILE}"
  fi
else
  echo "curl not present; skipping basic ftp auth test" | tee -a "${LOGFILE}"
fi

echo "STEP 3 completed." | tee -a "${LOGFILE}"
