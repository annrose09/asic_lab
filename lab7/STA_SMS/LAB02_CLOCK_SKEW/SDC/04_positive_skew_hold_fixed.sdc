# LAB02_CLOCK_SKEW - 04_positive_skew_hold_fixed
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 5.0 [get_ports clk]

# Skew is created PHYSICALLY by delay cells in the clock network.
# Clock-network delay is only used when the clock is propagated.
set_propagated_clock [all_clocks]
