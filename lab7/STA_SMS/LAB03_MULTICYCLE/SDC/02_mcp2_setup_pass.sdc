# LAB03_MULTICYCLE - 02_mcp2_setup_pass
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 4.0 [get_ports clk]

# Setup multicycle ONLY. The hold check edge also moves forward by one
# period (to 4 ns) - look at the hold report to see this.
set_multicycle_path 2 -setup -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D]
