# 1 GHz clock
create_clock -name CLK -period 1.000 [get_ports clk]

set_clock_uncertainty 0.20 [get_clocks CLK]
set_clock_transition 0.10 [get_clocks CLK]

# External interface timing
set_input_delay  1.00 -clock [get_clocks CLK] [get_ports {xin[*] sample_valid}]
set_output_delay 1.00 -clock [get_clocks CLK] [get_ports {yout[*] yout_valid sample_ready}]

# Reset is asynchronous and is not a functional data path
set_false_path -from [get_ports rst]

# Representative output loading and design-rule constraints
set_load 0.05 [get_ports {yout[*] yout_valid sample_ready}]
set_max_transition 0.50 [current_design]
set_max_fanout 8 [current_design]