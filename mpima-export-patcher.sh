#!/usr/bin/env bash
# ==========================================
# MPIMA FTP Auto-Patcher
# One-command setup for Ubuntu servers
# Written by Benson Okello
# ==========================================

set -euo pipefail

ROOT_REQUIRED=true
SIMULATE=false
LOGDIR="logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RUN_LOG="${LOGDIR}/run-${TIMESTAMP}.log"

mkdir -p "${LOGDIR}"
echo "Run started: $(date -u)" | tee -a "${RUN_LOG}"

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --simulate|-n) SIMULATE=true ;;
  esac
done

if $ROOT_REQUIRED && [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: Must run as root (sudo)." | tee -a "${RUN_LOG}"
  exit 1
fi

echo "SIMULATE=${SIMULATE}" | tee -a "${RUN_LOG}"

run_script() {
  SCRIPT="$1"
  echo "----> Running ${SCRIPT}" | tee -a "${RUN_LOG}"
  if $SIMULATE; then
    bash "${SCRIPT}" --simulate 2>&1 | tee -a "${RUN_LOG}"
  else
    bash "${SCRIPT}" 2>&1 | tee -a "${RUN_LOG}"
  fi
  echo "----> Completed ${SCRIPT}" | tee -a "${RUN_LOG}"
}

# STEP 1: Environment check
run_script "scripts/step1-check-environment.sh"

# STEP 2: Install vsftpd (robust version)
run_script "scripts/step2-install-vsftpd.sh"

# STEP 3: Fix PAM configuration
run_script "scripts/step3-fix-pam.sh"

# STEP 4: Configure firewall (checks if UFW active)
run_script "scripts/step4-firewall.sh"

# STEP 5: Finalize vsftpd setup, restart & enable service
run_script "scripts/step5-finalize.sh"

echo "Run finished: $(date -u)" | tee -a "${RUN_LOG}"
echo "Logs saved to ${LOGDIR}/"
