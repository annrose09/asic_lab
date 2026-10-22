# ==============================================================
# LAB03_MULTICYCLE : 04_mcp2_short_period_fail
# MCP 2 is not enough when T = 3 ns
#
# Purpose  : T reduced to 3.0 ns, MCP 2 gives only 6 ns
# Expected : setup slack = 6.00 - 0.20 - 6.20 = -0.40 ns (VIOLATED) ; hold slack = +6.10 ns
#
# HOW TO RUN (from inside the LAB03_MULTICYCLE folder):
#   cd LAB03_MULTICYCLE
#   tempus -files SCRIPTS/04_mcp2_short_period_fail.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB03_MULTICYCLE folder:"
  puts "       cd LAB03_MULTICYCLE"
  puts "       tempus -files SCRIPTS/04_mcp2_short_period_fail.tcl"
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
read_sdc ./SDC/04_mcp2_short_period_fail.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Setup (late) check
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/04_mcp2_short_period_fail_setup.rpt

# 5.2) Hold (early) check
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/04_mcp2_short_period_fail_hold.rpt

puts ""
puts "LAB03_MULTICYCLE/04_mcp2_short_period_fail finished. Reports are in ./REPORTS/"
puts "Expected : setup slack = 6.00 - 0.20 - 6.20 = -0.40 ns (VIOLATED) ; hold slack = +6.10 ns"
