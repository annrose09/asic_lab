TEMPUS STA LABS - INDIVIDUAL, SELF-CONTAINED, BEGINNER-FRIENDLY PACKAGE
=======================================================================

Each lab is completely self-contained. There is no common.tcl and no shared
script. Every Tcl script directly names the library, netlist, SDC and report.

RUN RULE
--------
1. Enter the LAB folder.
2. Start Tempus with ONE experiment script (one fresh Tempus session per script).

  cd LAB01_SETUP_HOLD
  tempus -files SCRIPTS/01_setup_fail.tcl

Every report is printed on the Tempus screen AND saved in <LAB>/REPORTS/.
Type "exit" in the Tempus shell when you are done, then run the next script.

To run everything in batch mode (one Tempus session per script):
  ./run_all_labs.sh              (all labs)
  ./run_all_labs.sh LAB03_MULTICYCLE   (one lab)

LABS AND EXPECTED RESULTS
-------------------------
LAB01_SETUP_HOLD
  01_setup_fail                  setup  -0.40  VIOLATED
  02_setup_fixed                 setup  +0.60  MET
  03_hold_fail                   hold   -0.20  VIOLATED
  04_hold_fixed                  hold   +0.30  MET

LAB02_CLOCK_SKEW  (propagated clock, physical skew)
  01_negative_skew_setup_fail    setup  -0.40  VIOLATED
  02_negative_skew_setup_fixed   setup  +0.10  MET
  03_positive_skew_hold_fail     hold   -0.90  VIOLATED
  04_positive_skew_hold_fixed    hold   +0.10  MET

LAB03_MULTICYCLE
  01_normal_setup_fail           setup  -2.40  VIOLATED
  02_mcp2_setup_pass             setup  +1.60  MET    hold +2.10 (checked at 4 ns edge)
  03_mcp2_setup_hold_corrected   setup  +1.60  MET    hold +6.10
  04_mcp2_short_period_fail      setup  -0.40  VIOLATED  hold +6.10
  05_mcp3_pass                   setup  +2.60  MET    hold +6.10

LAB04_HALF_CYCLE
  01_half_setup_fail             setup  -0.40  VIOLATED
  02_half_setup_fixed            setup  +0.60  MET
  03_half_hold_check             hold   +9.10  MET

LAB05_FALSE_PATH
  01_before_false_path           cfg path setup -1.40 VIOLATED, data path +1.60
  02_after_false_path            cfg path: no constrained path, data path +1.60

LAB06_CLOCK_GATING
  01_cg_setup_pass               gating setup +1.50  MET
  02_cg_setup_fail               gating setup -0.30  VIOLATED
  03_cg_setup_fixed              gating setup +1.00  MET
  04_cg_hold_check               gating hold  +0.30  MET

Reference manual (hand calculations + run results): MANUAL/TEMPUS_STA_Reference_Lab_Manual.pdf / .docx
See CHANGES_V3.txt for the list of corrections made in this version.
