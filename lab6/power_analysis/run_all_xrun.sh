#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "STEP 1: RTL simulation and VCD generation"
./scripts/run_sim_xrun.sh

echo
echo "STEP 2: Verify all VCD files"
./scripts/check_vcd_files.sh

echo
echo "STEP 3: Cadence Genus synthesis + VCD-based power analysis"
./scripts/run_genus_all.sh

echo
echo "Experiment complete."
