# 4-tap FIR timing constraints
# Target clock: 100 MHz (10 ns period)

create_clock -name CLK -period 10.000 [get_ports clk]

# Clock quality assumptions
set_clock_uncertainty 0.20 [get_clocks CLK]
set_clock_transition  0.10 [get_clocks CLK]

# External input/output timing budgets
set_input_delay  1.00 -clock [get_clocks CLK] [get_ports xin]
set_output_delay 1.00 -clock [get_clocks CLK] [get_ports yout]

# Reset is asynchronous and is not treated as a functional data path
set_false_path -from [get_ports rst]

# Output loading and design-rule constraints
set_load 0.05 [get_ports yout]
set_max_transition 0.50 [current_design]
set_max_fanout 8 [current_design]
