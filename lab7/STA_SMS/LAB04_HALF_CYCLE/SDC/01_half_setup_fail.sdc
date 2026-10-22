# LAB04_HALF_CYCLE - 01_half_setup_fail
# Independent SDC file (no shared constraint script).
# Time unit: ns (from teaching_sta.lib)

create_clock -name CLK -period 8.0 -waveform {0 4} [get_ports clk]
