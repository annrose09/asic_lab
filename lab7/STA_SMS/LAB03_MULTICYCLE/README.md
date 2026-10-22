LAB03_MULTICYCLE - SELF-CONTAINED TEMPUS LAB
==============================================

Folder structure:
  LIB/      : local teaching_sta.lib
  NETLIST/  : gate-level Verilog netlist(s)
  SDC/      : one independent SDC file per experiment
  SCRIPTS/  : one independent Tempus Tcl run script per experiment
  REPORTS/  : generated timing reports (created/filled by the scripts)

HOW TO RUN  (always from inside THIS folder)
-----------
  cd LAB03_MULTICYCLE
  tempus -files SCRIPTS/01_normal_setup_fail.tcl

The scripts use direct relative paths (./LIB, ./NETLIST, ./SDC, ./REPORTS).
If you start Tempus from another folder the script stops with a clear
ERROR message instead of failing half-way.

Every report is printed on the Tempus screen AND saved in ./REPORTS/.

LAB NOTES
---------
Netlist: U_LAUNCH -> 12 x BUF_X1 -> U_CAPTURE
Data arrival = 0.20 + 12 x 0.50 = 6.20 ns

The exceptions use exactly the same start/end points as the reports:
    -from [get_pins U_LAUNCH/CLK] -to [get_pins U_CAPTURE/D]
(The old scripts reported -from U_LAUNCH/Q. A flop Q pin is not a valid
timing start point, so the report did not match the multicycle exception
and always showed the single-cycle -2.40 ns result.)
To confirm the multicycle is applied, look at the setup report: the
capture edge / "Phase Shift" becomes N x T (8 ns for MCP 2 at T = 4 ns).

Rule: whenever you write  set_multicycle_path N -setup,
      also write           set_multicycle_path N-1 -hold
so that the hold check goes back to the original (0 ns) edge.
Experiment 02 deliberately omits the hold companion so you can compare
its hold report (+2.10 ns, checked at 4 ns) with experiment 03 (+6.10 ns).

EXPERIMENTS
-----------
01_normal_setup_fail
  Title    : Single-cycle setup check FAIL
  Netlist  : NETLIST/mcp.v  (top: mcp_top)
  SDC      : SDC/01_normal_setup_fail.sdc
  Script   : SCRIPTS/01_normal_setup_fail.tcl
  Expected : setup slack = 4.00 - 0.20 - 6.20 = -2.40 ns (VIOLATED)
  Reports  :
             REPORTS/01_normal_setup_fail_setup.rpt

02_mcp2_setup_pass
  Title    : MCP 2 (setup only) -> setup PASS, hold edge moves
  Netlist  : NETLIST/mcp.v  (top: mcp_top)
  SDC      : SDC/02_mcp2_setup_pass.sdc
  Script   : SCRIPTS/02_mcp2_setup_pass.tcl
  Expected : setup slack = 8.00 - 0.20 - 6.20 = +1.60 ns ; hold checked at 4 ns edge: 6.20 - (4.00 + 0.10) = +2.10 ns
  Reports  :
             REPORTS/02_mcp2_setup_pass_setup.rpt
             REPORTS/02_mcp2_setup_pass_hold.rpt

03_mcp2_setup_hold_corrected
  Title    : MCP 2 setup + companion MCP 1 hold (correct pair)
  Netlist  : NETLIST/mcp.v  (top: mcp_top)
  SDC      : SDC/03_mcp2_setup_hold_corrected.sdc
  Script   : SCRIPTS/03_mcp2_setup_hold_corrected.tcl
  Expected : setup slack = +1.60 ns ; hold slack = 6.20 - (0.00 + 0.10) = +6.10 ns
  Reports  :
             REPORTS/03_mcp2_setup_hold_corrected_setup.rpt
             REPORTS/03_mcp2_setup_hold_corrected_hold.rpt

04_mcp2_short_period_fail
  Title    : MCP 2 is not enough when T = 3 ns
  Netlist  : NETLIST/mcp.v  (top: mcp_top)
  SDC      : SDC/04_mcp2_short_period_fail.sdc
  Script   : SCRIPTS/04_mcp2_short_period_fail.tcl
  Expected : setup slack = 6.00 - 0.20 - 6.20 = -0.40 ns (VIOLATED) ; hold slack = +6.10 ns
  Reports  :
             REPORTS/04_mcp2_short_period_fail_setup.rpt
             REPORTS/04_mcp2_short_period_fail_hold.rpt

05_mcp3_pass
  Title    : MCP 3 setup + MCP 2 hold at T = 3 ns -> PASS
  Netlist  : NETLIST/mcp.v  (top: mcp_top)
  SDC      : SDC/05_mcp3_pass.sdc
  Script   : SCRIPTS/05_mcp3_pass.tcl
  Expected : setup slack = 9.00 - 0.20 - 6.20 = +2.60 ns (MET) ; hold slack = +6.10 ns
  Reports  :
             REPORTS/05_mcp3_pass_setup.rpt
             REPORTS/05_mcp3_pass_hold.rpt
