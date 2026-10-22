# Common synthesis constraint for ALL FOUR power experiments.
# Keeping the same SDC avoids changing the mapped architecture between cases.
create_clock -name CLK -period 5.0 [get_ports clk]
set_clock_uncertainty 0.10 [get_clocks CLK]
set_clock_transition 0.10 [get_clocks CLK]

set_input_delay 0.50 -clock CLK \
    [remove_from_collection [all_inputs] [get_ports {clk rst_n}]]

set_output_delay 0.50 -clock CLK [all_outputs]
set_load 0.05 [all_outputs]

set_false_path -from [get_ports rst_n]
