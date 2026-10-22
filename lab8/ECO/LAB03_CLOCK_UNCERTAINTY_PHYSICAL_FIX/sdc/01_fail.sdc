create_clock -name CLK -period 4.4 [get_ports clk]
set_clock_uncertainty -setup 0.4 [get_clocks CLK]
