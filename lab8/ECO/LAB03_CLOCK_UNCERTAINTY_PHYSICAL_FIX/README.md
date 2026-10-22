LAB03_CLOCK_UNCERTAINTY_PHYSICAL_FIX: Setup with Clock Uncertainty / Margin

FOLDER CONTENTS
  lib/      Local teaching Liberty. No dependency on another lab.
  netlist/  01_fail.v and 02_fixed.v
  sdc/      01_fail.sdc and 02_fixed.sdc
  scripts/  Tempus Tcl launch scripts
  reports/  Output location when run_all.sh is used

RUN FROM THIS LAB DIRECTORY
  tempus -files scripts/01_run_fail.tcl
  tempus -files scripts/02_run_fixed.tcl
  ./run_all.sh

IMPORTANT
  The scripts read the local SDC with read_sdc after read_lib, read_verilog and set_top_module.
  Each script prints the expected SETUP and HOLD hand calculation (including launch-FF CLK->Q,
  library setup/hold, clock edges and uncertainty, exactly as Tempus computes them), then runs
  report_timing -late (setup) and report_timing -early (hold) for comparison.
  Exact report formatting/slack should be verified in your installed Cadence Tempus version.

See the package-level Beginner Self-Study Manual for equations and explanations.
