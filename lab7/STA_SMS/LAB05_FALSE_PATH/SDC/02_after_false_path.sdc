# LAB05_FALSE_PATH - 02_after_false_path
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 5.0 [get_ports clk]

# Valid ONLY under the lab assumption: the cfg register is static in
# normal operation, so this path does not need single-cycle timing.
set_false_path -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D]
