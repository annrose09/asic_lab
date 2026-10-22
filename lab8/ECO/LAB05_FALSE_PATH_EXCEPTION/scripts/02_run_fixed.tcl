# Correct False-Path Timing Exception - FIX
# Run from this lab directory: tempus -files scripts/02_run_fixed.tcl
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set LAB_DIR [file normalize [file join $SCRIPT_DIR ..]]
set LIB [file join $LAB_DIR lib teaching_sta_physical.lib]
set NETLIST [file join $LAB_DIR netlist 02_fixed.v]
set SDC [file join $LAB_DIR sdc 02_fixed.sdc]

read_lib $LIB
read_verilog $NETLIST
set_top_module false_path_top
read_sdc $SDC

puts ""
puts "=================================================================="
puts "LAB05 FALSE-PATH EXCEPTION - AFTER JUSTIFIED EXCEPTION"
puts "=================================================================="
puts "Clock         : CLK period 5.00 ns, ideal"
puts "Library       : CLK->Q = 0.20, setup = 0.20, hold = 0.10 ns"
puts "Setup required: 5.00 - 0.20 = 4.80 ns     Hold required: 0.00 + 0.10 = 0.10 ns"
puts ""
puts "DATA path     : U_DATA_L -> 6 x BUF_X1 -> U_DATA_C/D"
puts "  Arrival     : 0.20 + 6 x 0.50 = 3.20 ns"
puts "  Setup slack : 4.80 - 3.20 = +1.60 ns -> MET"
puts "  Hold slack  : 3.20 - 0.10 = +3.10 ns -> MET"
puts ""
puts "CFG path      : U_CFG_L -> 12 x BUF_X1 -> U_CFG_C/D"
puts "  Arrival     : 0.20 + 12 x 0.50 = 6.20 ns"
puts "  If timed    : setup -1.40 ns, hold +6.10 ns (arithmetic only)"
puts "SDC correction: set_false_path -from \[get_cells U_CFG_L\] -to \[get_pins U_CFG_C/D\]"
puts "Result        : CFG path is EXCLUDED from BOTH setup and hold analysis;"
puts "                it does NOT gain positive slack (physical delay is unchanged)."
puts "Expected      : worst setup/hold reports show only the DATA path; the explicit"
puts "                CFG report should find no constrained path."
puts "=================================================================="
puts "ACTUAL TEMPUS TIMING REPORTS FOLLOW"
puts "=================================================================="
puts "\n----- WORST SETUP paths (late) -----"
report_timing -late -path_type full_clock -max_paths 5
puts "\n----- WORST HOLD paths (early) -----"
report_timing -early -path_type full_clock -max_paths 5
puts "\n----- CFG path after set_false_path (expect: no constrained path) -----"
report_timing -late -path_type full_clock -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D] -max_paths 1
exit
