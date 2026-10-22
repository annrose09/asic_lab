# Setup with Clock Uncertainty / Margin - FIX
# Run from this lab directory: tempus -files scripts/02_run_fixed.tcl
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set LAB_DIR [file normalize [file join $SCRIPT_DIR ..]]
set LIB [file join $LAB_DIR lib teaching_sta_physical.lib]
set NETLIST [file join $LAB_DIR netlist 02_fixed.v]
set SDC [file join $LAB_DIR sdc 02_fixed.sdc]

read_lib $LIB
read_verilog $NETLIST
set_top_module skew_physical
read_sdc $SDC

puts ""
puts "=================================================================="
puts "LAB03 CLOCK UNCERTAINTY SETUP FIX - FIX: EXPECTED HAND CALCULATION (Tempus conventions)"
puts "=================================================================="
puts "Clock         : CLK period 4.40 ns, ideal (0 latency), set_clock_uncertainty -setup 0.40"
puts "Netlist change: 8 x BUF_X1 replaced by 8 x BUF_X2 (clock/SDC UNCHANGED)"
puts "Path          : U_LAUNCH/CLK -> U_LAUNCH/Q -> 8 x BUF_X2 -> U_CAPTURE/D"
puts "Launch FF     : DFFPOS_X1 (rising edge), capture FF: DFFPOS_X1 (rising edge)"
puts "Library       : CLK->Q = 0.20, setup = 0.20, hold = 0.10 ns"
puts "Data path     : 8 x 0.25 = 2.00 ns"
puts "Arrival time  : CLK->Q + data = 0.20 + 2.00 = 2.20 ns"
puts "                (Tempus times every reg-to-reg path from the launch CLOCK edge,"
puts "                 so the launch FF CLK->Q delay is always inside the arrival time)"
puts ""
puts "--- SETUP CHECK (report_timing -late) ---"
puts "Launch edge   : 0.00 ns, capture edge: 4.40 ns"
puts "Phase shift   : 4.40 - 0.00 = 4.40 ns"
puts "Required time : phase shift - setup - uncertainty = 4.40 - 0.20 - 0.40 = 3.80 ns"
puts "Setup slack   : Required - Arrival = 3.80 - 2.20 = +1.60 ns  -> MET"
puts ""
puts "--- HOLD CHECK (report_timing -early) ---"
puts "Launch edge   : 0.00 ns, hold capture edge: 0.00 ns"
puts "Phase shift   : 0.00 - 0.00 = 0.00 ns"
puts "Required time : phase shift + hold = 0.00 + 0.10 = 0.10 ns"
puts "Hold slack    : Arrival - Required = 2.20 - 0.10 = +2.10 ns  -> MET"
puts ""
puts "Expected      : SETUP PASS with the 0.40 ns uncertainty RETAINED, hold MET"
puts "Improvement   : +1.60 - (-0.40) = 2.00 ns"
puts "Physical idea : Preserve clock margin and optimize the data path."
puts "=================================================================="
puts "ACTUAL TEMPUS TIMING REPORTS FOLLOW"
puts "=================================================================="
puts "\n----- SETUP (late) report -----"
report_timing -late -path_type full_clock -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
puts "\n----- HOLD (early) report -----"
report_timing -early -path_type full_clock -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
exit
