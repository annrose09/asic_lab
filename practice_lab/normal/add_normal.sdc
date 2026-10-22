# Combinational design constraints
set_input_delay  1.0 -clock [get_clocks VIRTUAL_CLK] [all_inputs]
set_output_delay 1.0 -clock [get_clocks VIRTUAL_CLK] [all_outputs]
set_load 0.05 [all_outputs]
set_max_transition 0.50 [current_design]
set_max_fanout 8 [current_design]
