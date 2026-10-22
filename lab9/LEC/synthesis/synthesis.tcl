# ------------------------------------------------------------------
# Genus synthesis - GOLDEN RTL  (LEC PASS case)
# Run from the synthesis/ directory:   genus -files synthesis.tcl
# ------------------------------------------------------------------
# ======================= EDIT PATHS HERE =========================
# Folder that holds your 90nm Liberty (.lib) file, and its file name.
# Example (common Cadence 90nm install):
#   /home/install/FOUNDRY/digital/90nm/dig/lib/   +   slow.lib
set LIB_DIR   /home/install/FOUNDRY/digital/90nm/dig/lib/
set LIB_NAME  slow.lib
set RTL_DIR   ../RTL/
set SDC_FILE  ../Constraints/constraints_top.sdc
# =================================================================

file mkdir reports outputs

set_db init_lib_search_path $LIB_DIR
set_db init_hdl_search_path $RTL_DIR
read_libs $LIB_NAME

read_hdl design.v
elaborate design_top
check_design -unresolved

read_sdc $SDC_FILE

set_db syn_generic_effort medium
set_db syn_map_effort     medium
set_db syn_opt_effort     medium

syn_generic
syn_map
syn_opt

# Reports
report_timing > reports/report_timing.rpt
report_power  > reports/report_power.rpt
report_area   > reports/report_area.rpt
report_qor    > reports/report_qor.rpt

# Outputs (netlist is the LEC revised design for the PASS case)
write_hdl > outputs/design_netlist.v
write_sdc > outputs/design_sdc.sdc

exit
