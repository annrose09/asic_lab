#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$LAB_DIR"

mkdir -p vcd
rm -f vcd/*.vcd
rm -f clk_low.vcd clk_high.vcd data_low.vcd data_high.vcd

run_case () {
    CASE="$1"
    TB="$2"
    VCD="$3"

    echo
    echo "===================================================="
    echo "Simulating: $CASE"
    echo "===================================================="

    xrun -64bit -clean -access +rwc \
        rtl/activity_power_top.v \
        "tb/$TB"

    if [ ! -f "$VCD" ]; then
        echo "ERROR: Expected VCD was not generated: $VCD"
        exit 1
    fi

    mv "$VCD" "vcd/$VCD"
    echo "Generated: vcd/$VCD"
}

run_case "LOW CLOCK ACTIVITY"  "tb_clk_low.v"   "clk_low.vcd"
run_case "HIGH CLOCK ACTIVITY" "tb_clk_high.v"  "clk_high.vcd"
run_case "LOW DATA ACTIVITY"   "tb_data_low.v"  "data_low.vcd"
run_case "HIGH DATA ACTIVITY"  "tb_data_high.v" "data_high.vcd"

echo
echo "===================================================="
echo "ALL VCD FILES GENERATED SUCCESSFULLY"
echo "===================================================="
ls -lh vcd/*.vcd
