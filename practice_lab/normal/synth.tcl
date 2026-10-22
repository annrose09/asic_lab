
set TOP_MODULE "add_normal"

set_db init_lib_search_path /home/install/FOUNDRY/digital/90nm/dig/lib
set_db init_hdl_search_path /home/vlsi52/24bvd1013/practice_lab/normal

read_libs slow.lib
read_hdl {add_normal.v}
elaborate
create_clock -name VIRTUAL_CLK -period 10.0
read_sdc add_normal.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium
syn_generic
write_hdl > output/netlist/${TOP_MODULE}_generic.v
syn_map
write_hdl > output/netlist/${TOP_MODULE}_mapped.v
syn_opt
write_hdl > output/netlist/${TOP_MODULE}_opt.v

write_sdc > output/constraints/${TOP_MODULE}_synth.sdc

report_timing > output/reports/${TOP_MODULE}_timing.rpt
report_power > output/reports/${TOP_MODULE}_power.rpt
report_area > output/reports/${TOP_MODULE}_area.rpt
report_gates > output/reports/${TOP_MODULE}_gates.rpt
report_qor > output/reports/${TOP_MODULE}_qor.rpt

gui_show
