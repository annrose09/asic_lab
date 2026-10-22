# Standalone Activity-Based Power Analysis Lab — Simulation First, Then Cadence Genus

## Objective

Use **one RTL design** and four simulation workloads to show that dynamic power changes with switching activity.

Two independent experiments are included:

1. **Clock activity experiment**
   - LOW clock activity: 20 MHz
   - HIGH clock activity: 200 MHz
   - Data is kept nearly constant.

2. **Data activity experiment**
   - Clock fixed at 100 MHz in both cases.
   - LOW data activity: operands change once every 10 cycles.
   - HIGH data activity: operands change every cycle with many bit transitions.

The important relationship is:

```text
Pdynamic ≈ alpha × C × V^2 × f
```

For the clock experiment, `f` changes strongly.
For the data experiment, `alpha` changes strongly.

---

## Folder structure

```text
Activity_Based_Power_Analysis_Standalone_Lab/
├── rtl/
│   └── activity_power_top.v
├── tb/
│   ├── tb_clk_low.v
│   ├── tb_clk_high.v
│   ├── tb_data_low.v
│   └── tb_data_high.v
├── vcd/
├── sdc/
│   └── activity_power_top.sdc
├── lib/
│   └── teaching_base.lib
├── scripts/
│   ├── run_sim_xrun.sh
│   ├── run_sim_iverilog.sh
│   ├── run_genus_clk_low.tcl
│   ├── run_genus_clk_high.tcl
│   ├── run_genus_data_low.tcl
│   ├── run_genus_data_high.tcl
│   ├── run_genus_all.sh
│   └── check_vcd_activity.py
├── reports/
├── netlist/
├── RESULTS_TEMPLATE.md
└── run_all_xrun.sh
```

---

# STEP 1 — Simulation

Use Cadence Xcelium:

```bash
./scripts/run_sim_xrun.sh
```

This generates:

```text
vcd/clk_low.vcd
vcd/clk_high.vcd
vcd/data_low.vcd
vcd/data_high.vcd
```

If Xcelium is unavailable, an Icarus Verilog alternative is included:

```bash
./scripts/run_sim_iverilog.sh
```

You may inspect the generated activity with:

```bash
python3 scripts/check_vcd_activity.py
```

---

# STEP 2 — Cadence Genus

Run:

```bash
./scripts/run_genus_all.sh
```

or individually:

```bash
genus -f scripts/run_genus_clk_low.tcl
genus -f scripts/run_genus_clk_high.tcl
genus -f scripts/run_genus_data_low.tcl
genus -f scripts/run_genus_data_high.tcl
```

Your older Genus release uses:

```tcl
read_vcd "$VCD_FILE" -vcd_scope tb_name/dut
```

not `-scope`.

---

# Why the synthesis constraint is intentionally the same in all four cases

All four Genus scripts use the same SDC:

```tcl
create_clock -period 5.0 [get_ports clk]
```

This is deliberate.

If we changed the synthesis clock constraint between LOW-CLOCK and HIGH-CLOCK cases, Genus could choose different cells or a different mapping. Then the experiment would mix two effects:

```text
different activity
+
different synthesized hardware
```

Instead, we keep the synthesis target fixed and change only the VCD activity. Therefore the mapped architecture should remain the same/nearly the same and the reported power change can be attributed mainly to activity.

The VCD timestamps still contain the actual simulated switching frequency used for power annotation.

---

# Expected result

## Clock activity

```text
LOW CLOCK: 20 MHz
HIGH CLOCK: 200 MHz
```

Data changes only occasionally.

Expected:

```text
HIGH clock activity
       ↓
more FF clock-pin transitions
       ↓
higher internal/switching dynamic power
```

Leakage should remain similar because the hardware is the same.

## Data activity

Both use:

```text
100 MHz clock
```

LOW data:

```text
a,b,c change once every 10 cycles
```

HIGH data:

```text
a,b,c change every cycle
```

Expected:

```text
HIGH data activity
       ↓
more multiplier/adder/register data transitions
       ↓
higher switching/internal power
```

---

# Important validation

Do not compare only `Total Power`.

Record:

```text
Internal Power
Switching Power
Leakage Power
Total Power
Area
Gate Count
```

Use `RESULTS_TEMPLATE.md`.

---

# Important limitation

`lib/teaching_base.lib` is a synthetic teaching library. It is intended to demonstrate **power trends**, not real silicon power. Replace it with your actual PDK Liberty library for meaningful technology-specific numbers.

The lab is designed so that the workflow itself remains the same:

```text
RTL
 ↓
simulation
 ↓
VCD
 ↓
Genus synthesis
 ↓
read_vcd
 ↓
report power
```


---

# v2 CORRECTION — Xcelium VCD path handling

Some Xcelium installations run the simulation from a work/snapshot context where
a testbench statement such as:

```verilog
$dumpfile("vcd/data_high.vcd");
```

cannot open the relative `vcd/` directory.

Therefore v2 writes the VCD into the simulation working directory first:

```verilog
$dumpfile("data_high.vcd");
```

and `scripts/run_sim_xrun.sh` then moves the file into:

```text
vcd/data_high.vcd
```

The same fix is applied to all four cases.

## Recommended run sequence

```bash
cd Activity_Based_Power_Analysis_Standalone_Lab_v2
chmod +x scripts/*.sh run_all_xrun.sh

./scripts/run_sim_xrun.sh
./scripts/check_vcd_files.sh
python3 scripts/check_vcd_activity.py

genus -f scripts/run_genus_clk_low.tcl
genus -f scripts/run_genus_clk_high.tcl
genus -f scripts/run_genus_data_low.tcl
genus -f scripts/run_genus_data_high.tcl
```

Do not start Genus until:

```bash
./scripts/check_vcd_files.sh
```

prints:

```text
VCD check PASSED.
```


---

# v3 CORRECTION — Genus MAP-2 "requires an async clear flop"

If Genus reports:

```text
Unable to map design without a suitable flip-flop. [MAP-2]
Instance 'activity_regs_reg[0]' requires an async clear flip-flop.
```

the reason is that the previous RTL used:

```verilog
always @(posedge clk or negedge rst_n)
```

which requires a library flip-flop with an asynchronous clear/reset pin.

The supplied synthetic `teaching_base.lib` intentionally contains a simple
positive-edge `DFF_X1` without asynchronous reset. Therefore v3 changes the
teaching DUT to a **synchronous reset**:

```verilog
always @(posedge clk) begin
    if (!rst_n) begin
        ...
    end else begin
        ...
    end
end
```

This is appropriate for this activity-based power lab because the experiment is
about switching activity, not reset-cell architecture.

With this change Genus can map the registers using the supplied `DFF_X1`.

If you later replace the teaching library with a real PDK containing async-reset
flops, you may change the RTL back to:

```verilog
always @(posedge clk or negedge rst_n)
```

provided the real Liberty library includes a usable async-clear DFF.
