# ==============================================================
# LAB02_CLOCK_SKEW : 03_positive_skew_hold_fail
# Positive clock skew -> hold FAIL
#
# Purpose  : capture clock arrives 1.00 ns late (skew = +1.00 ns), short data path
# Expected : hold slack = (0.00 + 0.20) - (1.00 + 0.10) = -0.90 ns (VIOLATED)
#
# HOW TO RUN (from inside the LAB02_CLOCK_SKEW folder):
#   cd LAB02_CLOCK_SKEW
#   tempus -files SCRIPTS/03_positive_skew_hold_fail.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB02_CLOCK_SKEW folder:"
  puts "       cd LAB02_CLOCK_SKEW"
  puts "       tempus -files SCRIPTS/03_positive_skew_hold_fail.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/skew_hold_fail.v

# 3) Set the top-level design
set_top_module skew_hold_fail_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/03_positive_skew_hold_fail.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Hold (early) check with full clock paths
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 -path_type full_clock
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 -path_type full_clock > ./REPORTS/03_positive_skew_hold_fail_hold.rpt

puts ""
puts "LAB02_CLOCK_SKEW/03_positive_skew_hold_fail finished. Reports are in ./REPORTS/"
puts "Expected : hold slack = (0.00 + 0.20) - (1.00 + 0.10) = -0.90 ns (VIOLATED)"
