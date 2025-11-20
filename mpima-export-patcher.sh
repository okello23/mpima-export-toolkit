#!/usr/bin/env bash
set -euo pipefail

### Orchestrator for mpima → ALIS FTP setup (vsftpd)
# Usage:
#   sudo ./mpima-export-patcher.sh          # run for real
#   sudo ./mpima-export-patcher.sh --simulate  # dry-run (no apt installs, no firewall)

ROOT_REQUIRED=true
SIMULATE=false
LOGDIR="logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RUN_LOG="${LOGDIR}/run-${TIMESTAMP}.log"

mkdir -p "${LOGDIR}"
echo "Run started: $(date -u)" | tee -a "${RUN_LOG}"

for arg in "$@"; do
  case "$arg" in
    --simulate) SIMULATE=true ;;
    -n) SIMULATE=true ;;
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

# Step 1
run_script "scripts/step1-check-environment.sh"

# Step 2
run_script "scripts/step2-setup-proxy.sh"

# Step 3
run_script "scripts/step3-validate-export.sh"

# Step 4
run_script "scripts/step4-run-diagnostics.sh"

echo "Run finished: $(date -u)" | tee -a "${RUN_LOG}"
echo "Logs saved to ${LOGDIR}/"
