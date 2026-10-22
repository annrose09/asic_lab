LAB05_FALSE_PATH - SELF-CONTAINED TEMPUS LAB
==============================================

Folder structure:
  LIB/      : local teaching_sta.lib
  NETLIST/  : gate-level Verilog netlist(s)
  SDC/      : one independent SDC file per experiment
  SCRIPTS/  : one independent Tempus Tcl run script per experiment
  REPORTS/  : generated timing reports (created/filled by the scripts)

HOW TO RUN  (always from inside THIS folder)
-----------
  cd LAB05_FALSE_PATH
  tempus -files SCRIPTS/01_before_false_path.tcl

The scripts use direct relative paths (./LIB, ./NETLIST, ./SDC, ./REPORTS).
If you start Tempus from another folder the script stops with a clear
ERROR message instead of failing half-way.

Every report is printed on the Tempus screen AND saved in ./REPORTS/.

LAB NOTES
---------
Two independent reg-to-reg paths on the same clock:
  U_DATA_L -> 6 x BUF_X1  -> U_DATA_C   (3.20 ns, functional)
  U_CFG_L  -> 12 x BUF_X1 -> U_CFG_C    (6.20 ns, quasi-static config)

The false path uses valid start/end points (flop CLK pin -> flop D pin):
  set_false_path -from [get_pins U_CFG_L/CLK] -to [get_pins U_CFG_C/D]
(A flop Q pin is NOT a valid timing start point, so -from [get_pins U_CFG_L/Q]
may be ignored by the tool with a warning.)

In 02, the first report is expected to print a message like
"No constrained timing paths found" - that is the proof the exception works.

EXPERIMENTS
-----------
01_before_false_path
  Title    : Before set_false_path: config path violates
  Netlist  : NETLIST/false_path.v  (top: false_path_top)
  SDC      : SDC/01_before_false_path.sdc
  Script   : SCRIPTS/01_before_false_path.tcl
  Expected : config path slack = 5.00 - 0.20 - 6.20 = -1.40 ns (VIOLATED); data path +1.60 ns
  Reports  :
             REPORTS/01_before_false_path_cfg_setup.rpt
             REPORTS/01_before_false_path_data_setup.rpt

02_after_false_path
  Title    : After set_false_path: config path is no longer timed
  Netlist  : NETLIST/false_path.v  (top: false_path_top)
  SDC      : SDC/02_after_false_path.sdc
  Script   : SCRIPTS/02_after_false_path.tcl
  Expected : config path: no constrained path reported; data path slack = 5.00 - 0.20 - 3.20 = +1.60 ns (MET)
  Reports  :
             REPORTS/02_after_false_path_cfg_setup.rpt
             REPORTS/02_after_false_path_top5_setup.rpt
