# ==============================================================
# LAB04_HALF_CYCLE : 03_half_hold_check
# Half-cycle hold check (easy to meet)
#
# Purpose  : hold of a neg -> pos path gets an extra half period of margin
# Expected : hold slack = (5.00 + 4.20) - (0.00 + 0.10) = +9.10 ns (MET)
#
# HOW TO RUN (from inside the LAB04_HALF_CYCLE folder):
#   cd LAB04_HALF_CYCLE
#   tempus -files SCRIPTS/03_half_hold_check.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB04_HALF_CYCLE folder:"
  puts "       cd LAB04_HALF_CYCLE"
  puts "       tempus -files SCRIPTS/03_half_hold_check.tcl"
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
read_sdc ./SDC/03_half_hold_check.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Hold (early) check
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1
report_timing -early -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D] -max_paths 1 > ./REPORTS/03_half_hold_check_hold.rpt

puts ""
puts "LAB04_HALF_CYCLE/03_half_hold_check finished. Reports are in ./REPORTS/"
puts "Expected : hold slack = (5.00 + 4.20) - (0.00 + 0.10) = +9.10 ns (MET)"
