from pathlib import Path
import re

vcd_dir = Path(__file__).resolve().parents[1] / "vcd"

def stats(path):
    text = path.read_text(errors="ignore")
    # Count timestamp changes and value-change records as a simple sanity metric.
    timestamps = len(re.findall(r'^#\d+', text, re.M))
    scalar_changes = len(re.findall(r'^[01xXzZ][!-~]$', text, re.M))
    vector_changes = len(re.findall(r'^b[01xXzZ]+\s+\S+$', text, re.M))
    return timestamps, scalar_changes, vector_changes

for name in ["clk_low.vcd","clk_high.vcd","data_low.vcd","data_high.vcd"]:
    p=vcd_dir/name
    if not p.exists():
        print(f"MISSING: {name}")
        continue
    t,s,v=stats(p)
    print(f"{name:14s} timestamps={t:5d} scalar_changes={s:6d} vector_changes={v:6d}")
