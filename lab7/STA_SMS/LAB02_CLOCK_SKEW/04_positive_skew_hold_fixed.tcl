# ==============================================================
# LAB02_CLOCK_SKEW : 04_positive_skew_hold_fixed
# Positive clock skew -> hold FIXED by data-path delay
#
# Purpose  : same +1.00 ns skew, 2 x BUF_X1 (1.00 ns) added in the data path
# Expected : hold slack = (0.00 + 0.20 + 1.00) - (1.00 + 0.10) = +0.10 ns (MET)
#
# HOW TO RUN (from inside the LAB02_CLOCK_SKEW folder):
#   cd LAB02_CLOCK_SKEW
#   tempus -files SCRIPTS/04_positive_skew_hold_fixed.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB02_CLOCK_SKEW folder:"
  puts "       cd LAB02_CLOCK_SKEW"
  puts "       tempus -files SCRIPTS/04_positive_skew_hold_fixed.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/skew_hold_fixed.v

# 3) Set the top-level design
set_top_module skew_hold_fixed_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/04_positive_skew_hold_fixed.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Hold (early) check with full clock paths
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 -path_type full_clock
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 -path_type full_clock > ./REPORTS/04_positive_skew_hold_fixed_hold.rpt

puts ""
puts "LAB02_CLOCK_SKEW/04_positive_skew_hold_fixed finished. Reports are in ./REPORTS/"
puts "Expected : hold slack = (0.00 + 0.20 + 1.00) - (1.00 + 0.10) = +0.10 ns (MET)"
