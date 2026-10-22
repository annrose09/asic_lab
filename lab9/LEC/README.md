# Lab: Synthesis (Genus) + Logic Equivalence Check (Conformal LEC) — 90nm

Design: `design_top` — 9-bit registered unit
`sel=1 : y <= (a+b) ^ c`  `sel=0 : y <= (a-b) + c`, async active-low reset.

|Case|Golden|Revised|Expected result|
|-|-|-|-|
|PASS|`RTL/design.v`|netlist from `design.v`|All points **Equivalent**|
|FAIL|`RTL/design.v`|netlist from `design_faulty.v` (`^` replaced by `|`)|`y_reg[0..7]` **Non-equivalent**, `y_reg[8]` equivalent|

## Folder layout

```
Cadence_90nm_LEC_Updated/
├── RTL/          design.v (golden), design_faulty.v (bug)
├── Constraints/  constraints_top.sdc
├── LIB/          put your 90nm .lib here (or point the scripts to it)
├── synthesis/    synthesis.tcl, synthesis_faulty.tcl, reports/, outputs/
├── LEC/          lib_convert.do, lec_pass.do, lec_fail.do
├── logs/         all tool logs land here
└── run.sh        optional one-shot runner
```

## Step 0 — Edit paths (once per system)

Every script has an **EDIT PATHS HERE** block at the top.

* `synthesis/synthesis.tcl` and `synthesis/synthesis_faulty.tcl` → `LIB_DIR`, `LIB_NAME`
* `LEC/lib_convert.do` → `read library <your .lib>` line
* `LEC/lec_pass.do`, `LEC/lec_fail.do` → `read library` line

Two easy options:

1. Copy your 90nm library into `LIB/` as `slow.lib` → **no edits needed**.
2. Or put full paths in the scripts, e.g. `/home/install/FOUNDRY/digital/90nm/dig/lib/slow.lib`
(`slow.lib` is the usual name in the Cadence 90nm gsclib; use `typical.lib`/`fast.lib` if your lab says so).

Source the Cadence setup (`source ~/cshrc` or your lab's setup file) so that `genus` and `lec` are on PATH.

## Step 1 — Synthesis (golden RTL → PASS netlist)

```
cd synthesis
genus -files synthesis.tcl -log ../logs/genus_pass
```

Check: `logs/genus_pass.log` has no errors, `check_design` shows no unresolved references,
`outputs/design_netlist.v` exists, reports in `reports/`.

## Step 2 — Synthesis (faulty RTL → FAIL netlist)

```
genus -files synthesis_faulty.tcl -log ../logs/genus_fail
cd ..
```

Creates `synthesis/outputs/design_netlist_faulty.v`.

## Step 3 — Convert the library for LEC

```
cd LEC
lec -XL -nogui -color -64 -dofile lib_convert.do
```

Creates `LIB/slow.v`. *(Skip this step if you switch `lec_*.do` to the commented
`read library ... -liberty -both` line.)*

## Step 4 — LEC PASS case

```
lec -XL -nogui -dofile lec_pass.do
```

In `logs/lec_pass.log`, the compare summary should show every point **Equivalent**,
**Non-equivalent = 0**, and no unmapped points apart from expected ones.

## Step 5 — LEC FAIL case

```
lec -XL -nogui -dofile lec_fail.do
cd ..
```

In `logs/lec_fail.log`: **Non-equivalent = 8** (`y_reg[0]..y_reg[7]`); `y_reg[8]` is still
Equivalent because bit 8 of `{1'b0,c}` is 0 and `x^0 == x|0`.

To look at a failing point in the GUI, run without `-nogui` and drop `exit -force`, then use
**Debug → Diagnose** on a non-equivalent point to see the counter-example (e.g. `sel=1`, `a+b` and `c` both 1 in the same bit).

## One-shot alternative

```
chmod +x run.sh
./run.sh all        # synth -> lib -> pass -> fail -> summary
./run.sh clean      # remove generated files
```

## 
