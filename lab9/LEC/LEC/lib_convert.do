// ------------------------------------------------------------------
// Convert the 90nm Liberty (.lib) into a Verilog cell library for LEC
// Run from LEC/ :   lec -XL -nogui -color -64 -dofile lib_convert.do
//
// ======================= EDIT PATHS HERE =========================
// Line A : full path of your 90nm .lib  (same file Genus uses)
//          e.g. /home/install/FOUNDRY/digital/90nm/dig/lib/slow.lib
// Line B : where to write the Verilog library (used by lec_*.do)
// =================================================================
set log file ../logs/lib_convert.log -replace
read library  /home/install/FOUNDRY/digital/90nm/dig/lib/slow.lib -liberty
write library ../LIB/slow.v -verilog -replace
exit -force
