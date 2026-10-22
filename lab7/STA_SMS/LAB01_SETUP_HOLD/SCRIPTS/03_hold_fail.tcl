# ==============================================================
# LAB01_SETUP_HOLD : 03_hold_fail
# Hold check FAIL (short data path + hold uncertainty)
#
# Purpose  : direct FF-to-FF path (0.20 ns), hold uncertainty 0.30 ns
# Expected : hold slack = 0.20 - (0.10 + 0.30) = -0.20 ns (VIOLATED)
#
# HOW TO RUN (from inside the LAB01_SETUP_HOLD folder):
#   cd LAB01_SETUP_HOLD
#   tempus -files SCRIPTS/03_hold_fail.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB01_SETUP_HOLD folder:"
  puts "       cd LAB01_SETUP_HOLD"
  puts "       tempus -files SCRIPTS/03_hold_fail.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/hold_fail.v

# 3) Set the top-level design
set_top_module hold_fail_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/03_hold_fail.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Hold (early) check
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/03_hold_fail_hold.rpt

puts ""
puts "LAB01_SETUP_HOLD/03_hold_fail finished. Reports are in ./REPORTS/"
puts "Expected : hold slack = 0.20 - (0.10 + 0.30) = -0.20 ns (VIOLATED)"
