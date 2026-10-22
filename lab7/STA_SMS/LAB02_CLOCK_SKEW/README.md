LAB02_CLOCK_SKEW - SELF-CONTAINED TEMPUS LAB
==============================================

Folder structure:
  LIB/      : local teaching_sta.lib
  NETLIST/  : gate-level Verilog netlist(s)
  SDC/      : one independent SDC file per experiment
  SCRIPTS/  : one independent Tempus Tcl run script per experiment
  REPORTS/  : generated timing reports (created/filled by the scripts)

HOW TO RUN  (always from inside THIS folder)
-----------
  cd LAB02_CLOCK_SKEW
  tempus -files SCRIPTS/01_negative_skew_setup_fail.tcl

The scripts use direct relative paths (./LIB, ./NETLIST, ./SDC, ./REPORTS).
If you start Tempus from another folder the script stops with a clear
ERROR message instead of failing half-way.

Every report is printed on the Tempus screen AND saved in ./REPORTS/.

LAB NOTES
---------
All four experiments use ONE clock (CLK) and create the skew physically
with delay cells in the clock network, so the SDC uses
    set_propagated_clock [all_clocks]
(Without this command Tempus treats the clock as ideal, ignores the clock
delay cells, and the skew disappears.)

  skew = capture clock latency - launch clock latency
  Negative skew hurts SETUP, positive skew hurts HOLD.

Reports use -path_type full_clock so the launch and capture clock paths
(including U_LCLK_DLY0 / U_CCLK_DLY0) are shown line by line.

The hold FAIL/FIXED SDC files are identical; only the data path changes.

EXPERIMENTS
-----------
01_negative_skew_setup_fail
  Title    : Negative clock skew -> setup FAIL
  Netlist  : NETLIST/skew_setup_fail.v  (top: skew_setup_fail_top)
  SDC      : SDC/01_negative_skew_setup_fail.sdc
  Script   : SCRIPTS/01_negative_skew_setup_fail.tcl
  Expected : setup slack = (5.00 + 0.00) - 0.20 - (1.00 + 4.20) = -0.40 ns (VIOLATED)
  Reports  :
             REPORTS/01_negative_skew_setup_fail_setup.rpt

02_negative_skew_setup_fixed
  Title    : Reduced negative skew -> setup PASS
  Netlist  : NETLIST/skew_setup_fixed.v  (top: skew_setup_fixed_top)
  SDC      : SDC/02_negative_skew_setup_fixed.sdc
  Script   : SCRIPTS/02_negative_skew_setup_fixed.tcl
  Expected : setup slack = (5.00 + 0.00) - 0.20 - (0.50 + 4.20) = +0.10 ns (MET)
  Reports  :
             REPORTS/02_negative_skew_setup_fixed_setup.rpt

03_positive_skew_hold_fail
  Title    : Positive clock skew -> hold FAIL
  Netlist  : NETLIST/skew_hold_fail.v  (top: skew_hold_fail_top)
  SDC      : SDC/03_positive_skew_hold_fail.sdc
  Script   : SCRIPTS/03_positive_skew_hold_fail.tcl
  Expected : hold slack = (0.00 + 0.20) - (1.00 + 0.10) = -0.90 ns (VIOLATED)
  Reports  :
             REPORTS/03_positive_skew_hold_fail_hold.rpt

04_positive_skew_hold_fixed
  Title    : Positive clock skew -> hold FIXED by data-path delay
  Netlist  : NETLIST/skew_hold_fixed.v  (top: skew_hold_fixed_top)
  SDC      : SDC/04_positive_skew_hold_fixed.sdc
  Script   : SCRIPTS/04_positive_skew_hold_fixed.tcl
  Expected : hold slack = (0.00 + 0.20 + 1.00) - (1.00 + 0.10) = +0.10 ns (MET)
  Reports  :
             REPORTS/04_positive_skew_hold_fixed_hold.rpt
