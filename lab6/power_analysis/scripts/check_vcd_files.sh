#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$LAB_DIR"

MISSING=0
for f in clk_low.vcd clk_high.vcd data_low.vcd data_high.vcd
do
    if [ ! -s "vcd/$f" ]; then
        echo "MISSING or EMPTY: vcd/$f"
        MISSING=1
    else
        echo "OK: vcd/$f"
    fi
done

if [ "$MISSING" -ne 0 ]; then
    echo "VCD check FAILED."
    exit 1
fi

echo "VCD check PASSED."
