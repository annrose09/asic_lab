
set TOP_MODULE "fir_4tap_shared_mult"

set_db init_lib_search_path /home/install/FOUNDRY/digital/180nm/dig/lib
set_db init_hdl_search_path /home/vlsi52/24bvd1013/lab4/FIR_LAB/fir_area_optimized/

read_libs fast.lib
read_hdl {fir_4tap_shared_mult.v}
elaborate 
read_sdc fir_4tap_shared_mult.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium
syn_generic
write_hdl > output/netlist/${TOP_MODULE}_genric.v
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

##gui_show