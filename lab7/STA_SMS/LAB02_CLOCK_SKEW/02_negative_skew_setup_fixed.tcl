# ==============================================================
# LAB02_CLOCK_SKEW : 02_negative_skew_setup_fixed
# Reduced negative skew -> setup PASS
#
# Purpose  : launch clock delay reduced to 0.50 ns (skew = -0.50 ns)
# Expected : setup slack = (5.00 + 0.00) - 0.20 - (0.50 + 4.20) = +0.10 ns (MET)
#
# HOW TO RUN (from inside the LAB02_CLOCK_SKEW folder):
#   cd LAB02_CLOCK_SKEW
#   tempus -files SCRIPTS/02_negative_skew_setup_fixed.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB02_CLOCK_SKEW folder:"
  puts "       cd LAB02_CLOCK_SKEW"
  puts "       tempus -files SCRIPTS/02_negative_skew_setup_fixed.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/skew_setup_fixed.v

# 3) Set the top-level design
set_top_module skew_setup_fixed_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/02_negative_skew_setup_fixed.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Setup (late) check with full clock paths
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 -path_type full_clock
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 -path_type full_clock > ./REPORTS/02_negative_skew_setup_fixed_setup.rpt

puts ""
puts "LAB02_CLOCK_SKEW/02_negative_skew_setup_fixed finished. Reports are in ./REPORTS/"
puts "Expected : setup slack = (5.00 + 0.00) - 0.20 - (0.50 + 4.20) = +0.10 ns (MET)"
