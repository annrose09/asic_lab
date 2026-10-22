// ------------------------------------------------------------------
// LEC FAIL case : golden RTL  vs  netlist synthesized from FAULTY RTL
// Expected      : NON-EQUIVALENT on y_reg[0] .. y_reg[7]
//                 y_reg[8] stays EQUIVALENT (bit 8 of {1'b0,c} is 0,
//                 and x XOR 0 == x OR 0)
// Run from LEC/ :   lec -XL -nogui -color -64 -dofile lec_fail.do
//
// ======================= EDIT PATHS HERE =========================
// 1st "read library" line : Verilog library made by lib_convert.do
//   (or delete it and use the commented Liberty line below instead)
// 1st "read design" line  : golden RTL (the CORRECT design.v)
// 2nd "read design" line  : netlist from synthesis_faulty.tcl
// =================================================================
set log file ../logs/lec_fail.log -replace

// ---- SETUP mode : read library + designs ----
read library ../LIB/slow.v -verilog -both
// read library ../LIB/slow.lib -liberty -both
read design ../RTL/design.v -verilog -golden
read design ../synthesis/outputs/design_netlist_faulty.v -verilog -revised
set root module design_top -golden
set root module design_top -revised
report design data

// ---- LEC mode : map key points and compare ----
set system mode lec
report unmapped points
add compared points -all
compare
exit -force
