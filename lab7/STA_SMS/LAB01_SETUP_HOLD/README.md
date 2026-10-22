LAB01_SETUP_HOLD - SELF-CONTAINED TEMPUS LAB
==============================================

Folder structure:
  LIB/      : local teaching_sta.lib
  NETLIST/  : gate-level Verilog netlist(s)
  SDC/      : one independent SDC file per experiment
  SCRIPTS/  : one independent Tempus Tcl run script per experiment
  REPORTS/  : generated timing reports (created/filled by the scripts)

HOW TO RUN  (always from inside THIS folder)
-----------
  cd LAB01_SETUP_HOLD
  tempus -files SCRIPTS/01_setup_fail.tcl

The scripts use direct relative paths (./LIB, ./NETLIST, ./SDC, ./REPORTS).
If you start Tempus from another folder the script stops with a clear
ERROR message instead of failing half-way.

Every report is printed on the Tempus screen AND saved in ./REPORTS/.

LAB NOTES
---------
Library values used:
  DFFPOS_X1 : CLK->Q 0.20 ns, setup 0.20 ns, hold 0.10 ns
  BUF_X1    : 0.50 ns

Setup experiments (01, 02) use NETLIST/setup_hold.v (8 x BUF_X1, 4.20 ns).
Hold experiments  (03, 04) use a short FF-to-FF path and a 0.30 ns hold
uncertainty. The hold FIX is a real fix: a delay buffer is inserted in the
data path (NETLIST/hold_fixed.v). The SDC is identical for 03 and 04.

EXPERIMENTS
-----------
01_setup_fail
  Title    : Setup check FAIL (clock period too short)
  Netlist  : NETLIST/setup_hold.v  (top: setup_hold_top)
  SDC      : SDC/01_setup_fail.sdc
  Script   : SCRIPTS/01_setup_fail.tcl
  Expected : setup slack = 4.00 - 0.20 - 4.20 = -0.40 ns (VIOLATED)
  Reports  :
             REPORTS/01_setup_fail_setup.rpt

02_setup_fixed
  Title    : Setup check FIXED (clock period relaxed)
  Netlist  : NETLIST/setup_hold.v  (top: setup_hold_top)
  SDC      : SDC/02_setup_fixed.sdc
  Script   : SCRIPTS/02_setup_fixed.tcl
  Expected : setup slack = 5.00 - 0.20 - 4.20 = +0.60 ns (MET)
  Reports  :
             REPORTS/02_setup_fixed_setup.rpt

03_hold_fail
  Title    : Hold check FAIL (short data path + hold uncertainty)
  Netlist  : NETLIST/hold_fail.v  (top: hold_fail_top)
  SDC      : SDC/03_hold_fail.sdc
  Script   : SCRIPTS/03_hold_fail.tcl
  Expected : hold slack = 0.20 - (0.10 + 0.30) = -0.20 ns (VIOLATED)
  Reports  :
             REPORTS/03_hold_fail_hold.rpt

04_hold_fixed
  Title    : Hold check FIXED (delay buffer added in the data path)
  Netlist  : NETLIST/hold_fixed.v  (top: hold_fixed_top)
  SDC      : SDC/04_hold_fixed.sdc
  Script   : SCRIPTS/04_hold_fixed.tcl
  Expected : hold slack = 0.70 - (0.10 + 0.30) = +0.30 ns (MET)
  Reports  :
             REPORTS/04_hold_fixed_hold.rpt
