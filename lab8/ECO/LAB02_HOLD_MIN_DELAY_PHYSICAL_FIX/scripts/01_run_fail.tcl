# Minimum-Delay / Hold-Style Physical Fix - FAIL
# Run from this lab directory: tempus -files scripts/01_run_fail.tcl
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set LAB_DIR [file normalize [file join $SCRIPT_DIR ..]]
set LIB [file join $LAB_DIR lib teaching_sta_physical.lib]
set NETLIST [file join $LAB_DIR netlist 01_fail.v]
set SDC [file join $LAB_DIR sdc 01_fail.sdc]

read_lib $LIB
read_verilog $NETLIST
set_top_module hold_physical
read_sdc $SDC

puts ""
puts "=================================================================="
puts "LAB02 MINIMUM-DELAY / HOLD FIX - FAIL: EXPECTED HAND CALCULATION (Tempus conventions)"
puts "=================================================================="
puts "Clock         : CLK period 10.00 ns, ideal"
puts "SDC           : set_min_delay 2.50 -from U_LAUNCH -to U_CAPTURE/D"
puts "Path          : U_LAUNCH/CLK -> U_LAUNCH/Q -> 2 x BUF_X1 -> U_CAPTURE/D"
puts "Launch FF     : DFFPOS_X1 (rising edge), capture FF: DFFPOS_X1 (rising edge)"
puts "Library       : CLK->Q = 0.20, setup = 0.20, hold = 0.10 ns"
puts "Data path     : 2 x 0.50 = 1.00 ns"
puts "Arrival time  : CLK->Q + data = 0.20 + 1.00 = 1.20 ns"
puts "                (Tempus times every reg-to-reg path from the launch CLOCK edge,"
puts "                 so the launch FF CLK->Q delay is always inside the arrival time)"
puts ""
puts "--- SETUP CHECK (report_timing -late) ---"
puts "Launch edge   : 0.00 ns, capture edge: 10.00 ns"
puts "Phase shift   : 10.00 - 0.00 = 10.00 ns"
puts "Required time : phase shift - setup = 10.00 - 0.20 = 9.80 ns"
puts "Setup slack   : Required - Arrival = 9.80 - 1.20 = +8.60 ns  -> MET"
puts ""
puts "--- HOLD CHECK (report_timing -early) ---"
puts "SDC           : set_min_delay 2.50 replaces the normal 0.00 ns hold relationship"
puts "Required time : min_delay + hold(lib) = 2.50 + 0.10 = 2.60 ns"
puts "Hold slack    : Arrival - Required = 1.20 - 2.60 = -1.40 ns  -> VIOLATED"
puts ""
puts "Without the SDC min delay the plain FF hold check would be 1.20 - 0.10 = +1.10 ns (MET);"
puts "the 2.50 ns set_min_delay is a deliberately tighter teaching requirement."
puts "Needed extra  : at least 2.60 - 1.20 = 1.40 ns of minimum delay"
puts "Expected      : HOLD (min-delay) FAIL, setup MET"
puts "=================================================================="
puts "ACTUAL TEMPUS TIMING REPORTS FOLLOW"
puts "=================================================================="
puts "\n----- HOLD / MIN-DELAY (early) report -----"
report_timing -early -path_type full_clock -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
puts "\n----- SETUP (late) report -----"
report_timing -late -path_type full_clock -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
exit
