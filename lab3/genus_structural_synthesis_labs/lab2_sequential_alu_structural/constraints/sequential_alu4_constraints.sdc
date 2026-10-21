create_clock -name CLK -period 10.0 [get_ports clk]
set_clock_uncertainty 0.20 [get_clocks CLK]
set_clock_transition 0.10 [get_clocks CLK]

set_input_delay  1.0 -clock CLK [remove_from_collection [all_inputs] [get_ports {clk rst}]]
set_output_delay 1.0 -clock CLK [all_outputs]
set_false_path -from [get_ports rst]

set_load 0.05 [all_outputs]
set_max_transition 0.50 [current_design]
set_max_fanout 8 [current_design]
