# ------------------------------------------------------------------
# Timing constraints for design_top  (units: ns, as in the 90nm lib)
# ------------------------------------------------------------------
create_clock -name clk -period 10 -waveform {0 5} [get_ports clk]
set_clock_transition 0.1 [get_clocks clk]
set_clock_uncertainty 0.2 [get_clocks clk]

# Data inputs listed explicitly. (The old pattern "c*" also matched
# the clock port "clk" and put an input delay on the clock.)
set_input_delay  1.0 -clock clk [get_ports {a[*] b[*] c[*] sel}]
set_output_delay 1.0 -clock clk [get_ports {y[*]}]

# Asynchronous reset is not timed
set_false_path -from [get_ports rst_n]
