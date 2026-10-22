# ==============================================================
# LAB04_HALF_CYCLE : 02_half_setup_fixed
# Half-cycle setup FIXED (T = 10 ns)
#
# Purpose  : launch at 5 ns, capture at 10 ns: T/2 = 5 ns available
# Expected : setup slack = 10.00 - 0.20 - (5.00 + 4.20) = +0.60 ns (MET)
#
# HOW TO RUN (from inside the LAB04_HALF_CYCLE folder):
#   cd LAB04_HALF_CYCLE
#   tempus -files SCRIPTS/02_half_setup_fixed.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB04_HALF_CYCLE folder:"
  puts "       cd LAB04_HALF_CYCLE"
  puts "       tempus -files SCRIPTS/02_half_setup_fixed.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/half_cycle.v

# 3) Set the top-level design
set_top_module half_cycle_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/02_half_setup_fixed.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Setup (late) check
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/02_half_setup_fixed_setup.rpt

puts ""
puts "LAB04_HALF_CYCLE/02_half_setup_fixed finished. Reports are in ./REPORTS/"
puts "Expected : setup slack = 10.00 - 0.20 - (5.00 + 4.20) = +0.60 ns (MET)"
