create_clock -name CLK -period 10.0 [get_ports clk]
# Teaching minimum-delay requirement on the reg-to-reg path.
# -from uses the launch FF (a valid timing startpoint = its clock pin), not U_LAUNCH/Q.
# For a flip-flop endpoint, Tempus adds the library hold time (0.10 ns) on top of 2.50 ns:
#   hold required = 2.50 + 0.10 = 2.60 ns
set_min_delay 2.5 -from [get_cells U_LAUNCH] -to [get_pins U_CAPTURE/D]
