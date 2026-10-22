# LAB01_SETUP_HOLD - 03_hold_fail
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 10.0 [get_ports clk]

# Hold margin required by the design (models clock jitter/skew budget)
set_clock_uncertainty -hold 0.30 [get_clocks CLK]
