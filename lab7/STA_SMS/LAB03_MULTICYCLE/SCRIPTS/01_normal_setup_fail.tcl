# ==============================================================
# LAB03_MULTICYCLE : 01_normal_setup_fail
# Single-cycle setup check FAIL
#
# Purpose  : 6.20 ns path with T = 4.0 ns and no exception
# Expected : setup slack = 4.00 - 0.20 - 6.20 = -2.40 ns (VIOLATED)
#
# HOW TO RUN (from inside the LAB03_MULTICYCLE folder):
#   cd LAB03_MULTICYCLE
#   tempus -files SCRIPTS/01_normal_setup_fail.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB03_MULTICYCLE folder:"
  puts "       cd LAB03_MULTICYCLE"
  puts "       tempus -files SCRIPTS/01_normal_setup_fail.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/mcp.v

# 3) Set the top-level design
set_top_module mcp_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/01_normal_setup_fail.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Setup (late) check
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/01_normal_setup_fail_setup.rpt

puts ""
puts "LAB03_MULTICYCLE/01_normal_setup_fail finished. Reports are in ./REPORTS/"
puts "Expected : setup slack = 4.00 - 0.20 - 6.20 = -2.40 ns (VIOLATED)"
