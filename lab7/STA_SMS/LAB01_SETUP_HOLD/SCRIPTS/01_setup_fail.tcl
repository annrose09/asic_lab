# ==============================================================
# LAB01_SETUP_HOLD : 01_setup_fail
# Setup check FAIL (clock period too short)
#
# Purpose  : 8-buffer path (4.20 ns) checked at T = 4.0 ns
# Expected : setup slack = 4.00 - 0.20 - 4.20 = -0.40 ns (VIOLATED)
#
# HOW TO RUN (from inside the LAB01_SETUP_HOLD folder):
#   cd LAB01_SETUP_HOLD
#   tempus -files SCRIPTS/01_setup_fail.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB01_SETUP_HOLD folder:"
  puts "       cd LAB01_SETUP_HOLD"
  puts "       tempus -files SCRIPTS/01_setup_fail.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/setup_hold.v

# 3) Set the top-level design
set_top_module setup_hold_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/01_setup_fail.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Setup (late) check
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/01_setup_fail_setup.rpt

puts ""
puts "LAB01_SETUP_HOLD/01_setup_fail finished. Reports are in ./REPORTS/"
puts "Expected : setup slack = 4.00 - 0.20 - 4.20 = -0.40 ns (VIOLATED)"
