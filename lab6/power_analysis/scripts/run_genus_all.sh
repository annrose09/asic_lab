#!/bin/sh
set -e

for CASE in clk_low clk_high data_low data_high
do
  echo "=== Genus power analysis: ${CASE} ==="
  genus -f scripts/run_genus_${CASE}.tcl
done

echo
echo "Power reports:"
ls -lh reports/*_power.rpt
