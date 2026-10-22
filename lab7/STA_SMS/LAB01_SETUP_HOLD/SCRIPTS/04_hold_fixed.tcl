# ==============================================================
# LAB01_SETUP_HOLD : 04_hold_fixed
# Hold check FIXED (delay buffer added in the data path)
#
# Purpose  : same constraints as 03, 1 x BUF_X1 added -> 0.70 ns data path
# Expected : hold slack = 0.70 - (0.10 + 0.30) = +0.30 ns (MET)
#
# HOW TO RUN (from inside the LAB01_SETUP_HOLD folder):
#   cd LAB01_SETUP_HOLD
#   tempus -files SCRIPTS/04_hold_fixed.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB01_SETUP_HOLD folder:"
  puts "       cd LAB01_SETUP_HOLD"
  puts "       tempus -files SCRIPTS/04_hold_fixed.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/hold_fixed.v

# 3) Set the top-level design
set_top_module hold_fixed_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/04_hold_fixed.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Hold (early) check
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/04_hold_fixed_hold.rpt

puts ""
puts "LAB01_SETUP_HOLD/04_hold_fixed finished. Reports are in ./REPORTS/"
puts "Expected : hold slack = 0.70 - (0.10 + 0.30) = +0.30 ns (MET)"
