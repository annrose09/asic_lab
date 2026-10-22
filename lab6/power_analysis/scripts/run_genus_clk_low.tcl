set SCRIPT_DIR [file normalize [file dirname [info script]]]
set LAB_DIR    [file normalize "$SCRIPT_DIR/.."]
set RPT        "$LAB_DIR/reports"
set NET        "$LAB_DIR/netlist"
set LIB_DIR    "$LAB_DIR/lib"

file mkdir $RPT
file mkdir $NET

set_db init_hdl_search_path "$LAB_DIR/rtl"
set_db init_lib_search_path "$LIB_DIR"

read_libs "$LIB_DIR/teaching_base.lib"

# Clear avoid/preserve where supported.
foreach lc [get_db lib_cells] {
    catch {set_db $lc .avoid false}
    catch {set_db $lc .preserve false}
}

read_hdl "$LAB_DIR/rtl/activity_power_top.v"
elaborate activity_power_top
check_design -unresolved

read_sdc "$LAB_DIR/sdc/activity_power_top.sdc"

syn_generic
syn_map
syn_opt

report area   > "$RPT/base_area.rpt"
report gates  > "$RPT/base_gates.rpt"
report timing > "$RPT/base_timing.rpt"

write_hdl > "$NET/activity_power_top_mapped.v"

set VCD_FILE "$LAB_DIR/vcd/clk_low.vcd"
if {![file exists $VCD_FILE]} {
    error "Missing VCD: $VCD_FILE. Run simulation first."
}

puts "Reading activity: $VCD_FILE"
read_vcd "$VCD_FILE" -vcd_scope tb_clk_low/dut

catch {report activity > "$RPT/clk_low_activity.rpt"}
report power > "$RPT/clk_low_power.rpt"

puts "DONE: clk_low"
