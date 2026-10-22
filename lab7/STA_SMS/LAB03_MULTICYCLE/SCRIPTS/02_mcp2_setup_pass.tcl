# ==============================================================
# LAB03_MULTICYCLE : 02_mcp2_setup_pass
# MCP 2 (setup only) -> setup PASS, hold edge moves
#
# Purpose  : set_multicycle_path 2 -setup only (no hold companion)
# Expected : setup slack = 8.00 - 0.20 - 6.20 = +1.60 ns ; hold checked at 4 ns edge: 6.20 - (4.00 + 0.10) = +2.10 ns
#
# HOW TO RUN (from inside the LAB03_MULTICYCLE folder):
#   cd LAB03_MULTICYCLE
#   tempus -files SCRIPTS/02_mcp2_setup_pass.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB03_MULTICYCLE folder:"
  puts "       cd LAB03_MULTICYCLE"
  puts "       tempus -files SCRIPTS/02_mcp2_setup_pass.tcl"
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
read_sdc ./SDC/02_mcp2_setup_pass.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Setup (late) check  -> look for 'Phase Shift' / capture edge = 8 ns
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -late -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/02_mcp2_setup_pass_setup.rpt

# 5.2) Hold (early) check -> hold is checked at the 4 ns edge (too pessimistic)
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/02_mcp2_setup_pass_hold.rpt

puts ""
puts "LAB03_MULTICYCLE/02_mcp2_setup_pass finished. Reports are in ./REPORTS/"
puts "Expected : setup slack = 8.00 - 0.20 - 6.20 = +1.60 ns ; hold checked at 4 ns edge: 6.20 - (4.00 + 0.10) = +2.10 ns"
