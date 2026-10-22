# LAB03_MULTICYCLE - 04_mcp2_short_period_fail
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 3.0 [get_ports clk]

set_multicycle_path 2 -setup -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D]
set_multicycle_path 1 -hold  -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D]
