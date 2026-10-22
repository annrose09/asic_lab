create_clock -name CLK -period 5.0 [get_ports clk]
# Functionally justified exception: CFG is quasi-static configuration data.
# -from uses the launch FF (a valid timing startpoint), not U_CFG_L/Q.
# set_false_path removes this path from BOTH setup and hold analysis.
set_false_path -from [get_cells U_CFG_L] -to [get_pins U_CFG_C/D]
