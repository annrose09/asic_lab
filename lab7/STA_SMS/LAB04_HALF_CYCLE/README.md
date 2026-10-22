LAB04_HALF_CYCLE - SELF-CONTAINED TEMPUS LAB
==============================================

Folder structure:
  LIB/      : local teaching_sta.lib
  NETLIST/  : gate-level Verilog netlist(s)
  SDC/      : one independent SDC file per experiment
  SCRIPTS/  : one independent Tempus Tcl run script per experiment
  REPORTS/  : generated timing reports (created/filled by the scripts)

HOW TO RUN  (always from inside THIS folder)
-----------
  cd LAB04_HALF_CYCLE
  tempus -files SCRIPTS/01_half_setup_fail.tcl

The scripts use direct relative paths (./LIB, ./NETLIST, ./SDC, ./REPORTS).
If you start Tempus from another folder the script stops with a clear
ERROR message instead of failing half-way.

Every report is printed on the Tempus screen AND saved in ./REPORTS/.

LAB NOTES
---------
U_LAUNCH is a NEGATIVE-edge flop (DFFNEG_X1), U_CAPTURE is POSITIVE-edge.
The data therefore has only half a clock period for setup:
  launch = falling edge (T/2), capture = next rising edge (T)
Data path = 0.20 + 8 x 0.50 = 4.20 ns

Note: the -from pin is U_LAUNCH/CLK. The report will show the launch
clock edge as the FALLING edge of CLK.

EXPERIMENTS
-----------
01_half_setup_fail
  Title    : Half-cycle (neg -> pos) setup FAIL
  Netlist  : NETLIST/half_cycle.v  (top: half_cycle_top)
  SDC      : SDC/01_half_setup_fail.sdc
  Script   : SCRIPTS/01_half_setup_fail.tcl
  Expected : setup slack = 8.00 - 0.20 - (4.00 + 4.20) = -0.40 ns (VIOLATED)
  Reports  :
             REPORTS/01_half_setup_fail_setup.rpt

02_half_setup_fixed
  Title    : Half-cycle setup FIXED (T = 10 ns)
  Netlist  : NETLIST/half_cycle.v  (top: half_cycle_top)
  SDC      : SDC/02_half_setup_fixed.sdc
  Script   : SCRIPTS/02_half_setup_fixed.tcl
  Expected : setup slack = 10.00 - 0.20 - (5.00 + 4.20) = +0.60 ns (MET)
  Reports  :
             REPORTS/02_half_setup_fixed_setup.rpt

03_half_hold_check
  Title    : Half-cycle hold check (easy to meet)
  Netlist  : NETLIST/half_cycle.v  (top: half_cycle_top)
  SDC      : SDC/03_half_hold_check.sdc
  Script   : SCRIPTS/03_half_hold_check.tcl
  Expected : hold slack = (5.00 + 4.20) - (0.00 + 0.10) = +9.10 ns (MET)
  Reports  :
             REPORTS/03_half_hold_check_hold.rpt
