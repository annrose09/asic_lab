# Correct False-Path Timing Exception - FAIL
# Run from this lab directory: tempus -files scripts/01_run_fail.tcl
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set LAB_DIR [file normalize [file join $SCRIPT_DIR ..]]
set LIB [file join $LAB_DIR lib teaching_sta_physical.lib]
set NETLIST [file join $LAB_DIR netlist 01_fail.v]
set SDC [file join $LAB_DIR sdc 01_fail.sdc]

read_lib $LIB
read_verilog $NETLIST
set_top_module false_path_top
read_sdc $SDC

puts ""
puts "=================================================================="
puts "LAB05 FALSE-PATH EXCEPTION - BEFORE EXCEPTION: EXPECTED HAND CALCULATION"
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
puts "  Setup slack : 4.80 - 6.20 = -1.40 ns -> VIOLATED"
puts "  Hold slack  : 6.20 - 0.10 = +6.10 ns -> MET"
puts "Expected CFG  : SETUP FAIL while it is analyzed as an ordinary timed path"
puts "Important     : A path must never be declared false merely because it fails."
puts "=================================================================="
puts "ACTUAL TEMPUS TIMING REPORTS FOLLOW"
puts "=================================================================="
puts "\n----- DATA SETUP (late) -----"
report_timing -late -path_type full_clock -from [get_pins U_DATA_L/CLK] -to [get_pins U_DATA_C/D] -max_paths 1
puts "\n----- DATA HOLD (early) -----"
report_timing -early -path_type full_clock -from [get_pins U_DATA_L/CLK] -to [get_pins U_DATA_C/D] -max_paths 1
puts "\n----- CFG SETUP (late) -----"
report_timing -late -path_type full_clock -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D] -max_paths 1
puts "\n----- CFG HOLD (early) -----"
report_timing -early -path_type full_clock -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D] -max_paths 1
exit
