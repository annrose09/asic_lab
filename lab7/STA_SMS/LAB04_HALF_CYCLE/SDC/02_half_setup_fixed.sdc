# LAB04_HALF_CYCLE - 02_half_setup_fixed
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 10.0 -waveform {0 5} [get_ports clk]
