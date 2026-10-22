# LAB03_MULTICYCLE - 03_mcp2_setup_hold_corrected
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 4.0 [get_ports clk]

# Correct multicycle pair: setup N, hold N-1
set_multicycle_path 2 -setup -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D]
set_multicycle_path 1 -hold  -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D]
