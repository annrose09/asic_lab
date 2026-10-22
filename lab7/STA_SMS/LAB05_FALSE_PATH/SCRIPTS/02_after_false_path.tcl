# ==============================================================
# LAB05_FALSE_PATH : 02_after_false_path
# After set_false_path: config path is no longer timed
#
# Purpose  : config path declared false; only the functional data path is timed
# Expected : config path: no constrained path reported; data path slack = 5.00 - 0.20 - 3.20 = +1.60 ns (MET)
#
# HOW TO RUN (from inside the LAB05_FALSE_PATH folder):
#   cd LAB05_FALSE_PATH
#   tempus -files SCRIPTS/02_after_false_path.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB05_FALSE_PATH folder:"
  puts "       cd LAB05_FALSE_PATH"
  puts "       tempus -files SCRIPTS/02_after_false_path.tcl"
  return
}
file mkdir ./REPORTS

# 1) Read the timing library
read_lib ./LIB/teaching_sta.lib

# 2) Read the gate-level Verilog netlist
read_verilog ./NETLIST/false_path.v

# 3) Set the top-level design
set_top_module false_path_top

# 4) Read the SDC constraints for this experiment
read_sdc ./SDC/02_after_false_path.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Config path (expect: no constrained timing path found)
report_timing -late -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D] -max_paths 1
report_timing -late -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D] -max_paths 1 > ./REPORTS/02_after_false_path_cfg_setup.rpt

# 5.2) Worst setup paths in the whole design (config path must be absent)
report_timing -late -max_paths 5
report_timing -late -max_paths 5 > ./REPORTS/02_after_false_path_top5_setup.rpt

puts ""
puts "LAB05_FALSE_PATH/02_after_false_path finished. Reports are in ./REPORTS/"
puts "Expected : config path: no constrained path reported; data path slack = 5.00 - 0.20 - 3.20 = +1.60 ns (MET)"
