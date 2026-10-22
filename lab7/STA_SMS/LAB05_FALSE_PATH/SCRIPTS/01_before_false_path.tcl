# ==============================================================
# LAB05_FALSE_PATH : 01_before_false_path
# Before set_false_path: config path violates
#
# Purpose  : 12-buffer config path (6.20 ns) timed at T = 5.0 ns
# Expected : config path slack = 5.00 - 0.20 - 6.20 = -1.40 ns (VIOLATED); data path +1.60 ns
#
# HOW TO RUN (from inside the LAB05_FALSE_PATH folder):
#   cd LAB05_FALSE_PATH
#   tempus -files SCRIPTS/01_before_false_path.tcl
# ==============================================================

# 0) Make sure we are in the lab folder, then create REPORTS/
if {![file exists ./LIB/teaching_sta.lib]} {
  puts "ERROR: run this script from inside the LAB05_FALSE_PATH folder:"
  puts "       cd LAB05_FALSE_PATH"
  puts "       tempus -files SCRIPTS/01_before_false_path.tcl"
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
read_sdc ./SDC/01_before_false_path.sdc

# 5) Timing reports
#    Each report is printed on the Tempus screen first,
#    then the same report is stored in ./REPORTS/

# 5.1) Config path setup check
report_timing -late -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D] -max_paths 1
report_timing -late -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D] -max_paths 1 > ./REPORTS/01_before_false_path_cfg_setup.rpt

# 5.2) Functional data path setup check
report_timing -late -from [get_pins U_DATA_L/CLK] -to [get_pins U_DATA_C/D] -max_paths 1
report_timing -late -from [get_pins U_DATA_L/CLK] -to [get_pins U_DATA_C/D] -max_paths 1 > ./REPORTS/01_before_false_path_data_setup.rpt

puts ""
puts "LAB05_FALSE_PATH/01_before_false_path finished. Reports are in ./REPORTS/"
puts "Expected : config path slack = 5.00 - 0.20 - 6.20 = -1.40 ns (VIOLATED); data path +1.60 ns"
