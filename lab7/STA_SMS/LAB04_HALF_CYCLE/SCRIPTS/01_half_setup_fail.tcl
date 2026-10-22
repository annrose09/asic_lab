# ==============================================================
# LAB04_HALF_CYCLE : 01_half_setup_fail
# Half-cycle (neg -> pos) setup FAIL
#
# Purpose  : launch on falling edge (4 ns), capture on rising edge (8 ns): only T/2 = 4 ns available
# Expected : setup slack = 8.00 - 0.20 - (4.00 + 4.20) = -0.40 ns (VIOLATED)
#
# HOW TO RUN (from inside the LAB04_HALF_CYCLE folder):
#   cd LAB04_HALF_CYCLE
#   tempus -files SCRIPTS/01_half_setup_fail.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB04_HALF_CYCLE folder:"
  puts "       cd LAB04_HALF_CYCLE"
  puts "       tempus -files SCRIPTS/01_half_setup_fail.tcl"
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
read_sdc ./SDC/01_half_setup_fail.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Setup (late) check
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/01_half_setup_fail_setup.rpt

puts ""
puts "LAB04_HALF_CYCLE/01_half_setup_fail finished. Reports are in ./REPORTS/"
puts "Expected : setup slack = 8.00 - 0.20 - (4.00 + 4.20) = -0.40 ns (VIOLATED)"
