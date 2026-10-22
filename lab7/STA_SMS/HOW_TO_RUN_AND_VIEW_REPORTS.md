TEMPUS STA LABS - HOW TO RUN AND VIEW REPORTS
=============================================

1) Always run a script from inside its LAB folder:

     cd LAB02_CLOCK_SKEW
     tempus -files SCRIPTS/03_positive_skew_hold_fail.tcl

   If you start from the wrong folder, the script prints an ERROR and stops.

2) Use a NEW Tempus session for every script (type "exit" first).
   Re-sourcing a second script in the same session would load a second
   copy of the library/netlist and mix constraints from two experiments.

3) Each timing report is generated twice (intentional, for teaching):
     report_timing ...                       -> shown on the Tempus screen
     report_timing ... > ./REPORTS/<name>.rpt -> stored in the REPORTS folder

4) View a stored report:
     cat  REPORTS/03_positive_skew_hold_fail_hold.rpt
     less REPORTS/03_positive_skew_hold_fail_hold.rpt

5) What to look for in a Tempus report header:
     Path 1: VIOLATED / MET  Setup|Hold Check with Pin ...
     Other End Arrival Time   -> capture clock arrival (skew shows up here)
     - Setup / + Hold         -> library constraint
     + Phase Shift            -> capture edge (N x T for a multicycle path)
     - Uncertainty            -> set_clock_uncertainty
     = Slack Time             -> the result

6) Batch run of all labs (one Tempus session per script):
     ./run_all_labs.sh
     ./run_all_labs.sh LAB01_SETUP_HOLD
