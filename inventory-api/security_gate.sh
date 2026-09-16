#!/usr/bin/env bash

set -euo pipefail

SEVERITY="${SEVERITY:-HIGH,CRITICAL}"
overall_status=0

log() {
    printf '[security] %s\n' "$*"
}

die() {
    log "FAIL: $*"
    exit 1
}

# Hadolint
log "Running Hadolint"

if hadolint Dockerfile; then
    log "Hadolint: PASS"
else
    status=$?
    log "Hadolint: FAIL (exit code ${status})"
    overall_status=1
fi

# Trivy configuration scan
log "Running Trivy config scan"

if trivy config --severity "$SEVERITY" --exit-code 1 .; then
    log "Trivy config: PASS"
else
    status=$?
    log "Trivy config: FAIL (exit code ${status})"
    overall_status=1
fi

# Trivy vulnerability scan
log "Running Trivy vulnerability scan"

if trivy fs --scanners vuln --severity "$SEVERITY" --exit-code 1 .; then
    log "Trivy vulnerability scan: PASS"
else
    status=$?
    log "Trivy vulnerability scan: FAIL (exit code ${status})"
    overall_status=1
fi

# Trivy secret scan
log "Running Trivy secret scan"

if trivy fs --scanners secret --exit-code 1 .; then
    log "Trivy secret scan: PASS"
else
    status=$?
    log "Trivy secret scan: FAIL (exit code ${status})"
    overall_status=1
fi

# Overall result
if [ "$overall_status" -eq 0 ]; then
    log "Overall: PASS"
    exit 0
else
    die "Overall: FAIL"
fi