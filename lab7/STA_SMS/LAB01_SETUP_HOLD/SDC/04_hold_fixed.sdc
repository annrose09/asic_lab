# LAB01_SETUP_HOLD - 04_hold_fixed
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 10.0 [get_ports clk]

# SAME constraint as 03_hold_fail: the fix is in the netlist, not the SDC
set_clock_uncertainty -hold 0.30 [get_clocks CLK]
