// ------------------------------------------------------------------
// LEC PASS case : golden RTL  vs  netlist synthesized from golden RTL
// Expected      : all compare points EQUIVALENT, 0 non-equivalent
// Run from LEC/ :   lec -XL -nogui -color -64 -dofile lec_pass.do
//
// ======================= EDIT PATHS HERE =========================
// 1st "read library" line : Verilog library made by lib_convert.do
//   (or delete it and use the commented Liberty line below instead -
//    then lib_convert.do is not needed)
// 1st "read design" line  : golden RTL
// 2nd "read design" line  : synthesized netlist from synthesis.tcl
// =================================================================
set log file ../logs/lec_pass.log -replace

// ---- SETUP mode : read library + designs ----
read library ../LIB/slow.v -verilog -both
// read library ../LIB/slow.lib -liberty -both
read design ../RTL/design.v -verilog -golden
read design ../synthesis/outputs/design_netlist.v -verilog -revised
set root module design_top -golden
set root module design_top -revised
report design data

// ---- LEC mode : map key points and compare ----
set system mode lec
report unmapped points
add compared points -all
compare

exit -force
