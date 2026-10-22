#!/bin/bash
set -e
cd "$(dirname "$0")"
mkdir -p reports
echo "===== FAIL / BEFORE ====="
tempus -files scripts/01_run_fail.tcl | tee reports/01_fail.log
echo "===== FIX / AFTER ====="
tempus -files scripts/02_run_fixed.tcl | tee reports/02_fixed.log
