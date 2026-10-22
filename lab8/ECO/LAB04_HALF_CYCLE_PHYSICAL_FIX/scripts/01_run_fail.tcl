# Half-Cycle Setup Violation and Physical Fix - FAIL
# Run from this lab directory: tempus -files scripts/01_run_fail.tcl
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set LAB_DIR [file normalize [file join $SCRIPT_DIR ..]]
set LIB [file join $LAB_DIR lib teaching_sta_physical.lib]
set NETLIST [file join $LAB_DIR netlist 01_fail.v]
set SDC [file join $LAB_DIR sdc 01_fail.sdc]

read_lib $LIB
read_verilog $NETLIST
set_top_module half_physical
read_sdc $SDC

puts ""
puts "=================================================================="
puts "LAB04 HALF-CYCLE SETUP FIX - FAIL: EXPECTED HAND CALCULATION (Tempus conventions)"
puts "=================================================================="
puts "Clock         : CLK period 8.00 ns, -waveform {0 4} (rise 0, fall 4), ideal"
puts "Path          : U_LAUNCH/CLK -> U_LAUNCH/Q -> 8 x BUF_X1 -> U_CAPTURE/D"
puts "Launch FF     : DFFNEG_X1 (falling edge), capture FF: DFFPOS_X1 (rising edge)"
puts "Library       : CLK->Q = 0.20, setup = 0.20, hold = 0.10 ns"
puts "Data path     : 8 x 0.50 = 4.00 ns"
puts "Arrival time  : CLK->Q + data = 0.20 + 4.00 = 4.20 ns"
puts "                (Tempus times every reg-to-reg path from the launch CLOCK edge,"
puts "                 so the launch FF CLK->Q delay is always inside the arrival time)"
puts ""
puts "--- SETUP CHECK (report_timing -late) ---"
puts "Launch edge   : 4.00 ns, capture edge: 8.00 ns"
puts "Phase shift   : 8.00 - 4.00 = 4.00 ns"
puts "Required time : phase shift - setup = 4.00 - 0.20 = 3.80 ns"
puts "Setup slack   : Required - Arrival = 3.80 - 4.20 = -0.40 ns  -> VIOLATED"
puts ""
puts "--- HOLD CHECK (report_timing -early) ---"
puts "Launch edge   : 4.00 ns, hold capture edge: 0.00 ns"
puts "Phase shift   : 0.00 - 4.00 = -4.00 ns"
puts "Required time : phase shift + hold = -4.00 + 0.10 = -3.90 ns"
puts "Hold slack    : Arrival - Required = 4.20 - (-3.90) = +8.10 ns  -> MET"
puts ""
puts "Absolute view : arrival = 4.00 + 4.20 = 8.20 ns, setup required = 8.00 - 0.20 = 7.80 ns -> same slack -0.40 ns"
puts "Hold edges    : launch fall @4.00 vs. preceding capture rise @0.00 (equivalently next launch @12.00 vs capture @8.00)"
puts "Expected      : SETUP FAIL, hold MET"
puts "=================================================================="
puts "ACTUAL TEMPUS TIMING REPORTS FOLLOW"
puts "=================================================================="
puts "\n----- SETUP (late) report -----"
report_timing -late -path_type full_clock -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
puts "\n----- HOLD (early) report -----"
report_timing -early -path_type full_clock -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
exit
