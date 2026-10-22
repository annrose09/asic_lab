# ==============================================================================
# Tcl Script to Parse EDA Synthesis & Power Reports and Print Aligned Table
# ==============================================================================

set script_dir [file normalize [file dirname [info script]]]
set lab_dir    [file normalize "$script_dir/.."]
set reports_dir "$lab_dir/reports"

# --- Helper Procedure: Extract Cell Count & Cell Area from Area Report ---
proc parse_area_rpt {filepath} {
    set cell_count "-"
    set cell_area  "-"

    if {[catch {set fid [open $filepath r]} err]} {
        puts "Warning: Could not open $filepath: $err"
        return [list $cell_count $cell_area]
    }

    set in_table 0
    while {[gets $fid line] >= 0} {
        # Wait until we hit the table divider line
        if {[string match "*----------------*" $line]} {
            set in_table 1
            continue
        }
        # Once inside the table, find the row starting with activity_power_top
        if {$in_table} {
            set trimmed [string trim $line]
            if {[string match "activity_power_top*" $trimmed]} {
                set tokens [regexp -all -inline {\S+} $line]
                # tokens: [0]=activity_power_top, [1]=Cell Count, [2]=Cell Area
                if {[llength $tokens] >= 3} {
                    set cell_count [lindex $tokens 1]
                    set cell_area  [lindex $tokens 2]
                }
                break
            }
        }
    }
    close $fid
    return [list $cell_count $cell_area]
}

# --- Helper Procedure: Extract Power Values from Subtotal Row ---
proc parse_power_rpt {filepath} {
    set leakage "-"
    set internal "-"
    set switching "-"
    set total "-"

    if {[catch {set fid [open $filepath r]} err]} {
        puts "Warning: Could not open $filepath: $err"
        return [list $internal $switching $leakage $total]
    }

    while {[gets $fid line] >= 0} {
        if {[string match "*Subtotal*" $line]} {
            set tokens [regexp -all -inline {\S+} $line]
            if {[llength $tokens] >= 5} {
                set leakage   [lindex $tokens 1]
                set internal  [lindex $tokens 2]
                set switching [lindex $tokens 3]
                set total     [lindex $tokens 4]
            }
            break
        }
    }
    close $fid
    return [list $internal $switching $leakage $total]
}

# --- Helper Procedure: Print Aligned Table Rows ---
proc print_row {metric low high expected} {
    puts [format "| %-17s | %-24s | %-24s | %-23s |" $metric $low $high $expected]
}

# --- 1. Gather Metrics from Files ---
puts "Parsing reports from '$reports_dir'...\n"

# Base Area & Gate Count Data (using base_area.rpt)
set base_metrics [parse_area_rpt [file join $reports_dir "base_area.rpt"]]
set gate_count   [lindex $base_metrics 0]
set cell_area    [lindex $base_metrics 1]

# Clock Activity Experiment Power Data
set clk_low_pwr  [parse_power_rpt [file join $reports_dir "clk_low_power.rpt"]]
set clk_high_pwr [parse_power_rpt [file join $reports_dir "clk_high_power.rpt"]]

# Data Activity Experiment Power Data
set data_low_pwr  [parse_power_rpt [file join $reports_dir "data_low_power.rpt"]]
set data_high_pwr [parse_power_rpt [file join $reports_dir "data_high_power.rpt"]]

# Unpack power metrics (Order: Internal, Switching, Leakage, Total)
foreach {clk_low_int clk_low_sw clk_low_lk clk_low_tot} $clk_low_pwr {}
foreach {clk_high_int clk_high_sw clk_high_lk clk_high_tot} $clk_high_pwr {}

foreach {data_low_int data_low_sw data_low_lk data_low_tot} $data_low_pwr {}
foreach {data_high_int data_high_sw data_high_lk data_high_tot} $data_high_pwr {}


# --- 2. Print Formatted Results Template to Terminal ---

# Section A
puts "## A. Clock Activity Experiment\n"
puts "Keep data nearly constant. Compare only clock activity.\n"
print_row "Metric" "LOW CLOCK (20 MHz VCD)" "HIGH CLOCK (200 MHz VCD)" "Expected"
puts "|-------------------|--------------------------|--------------------------|-------------------------|"
print_row "Cell area"      $cell_area    $cell_area    "Same/nearly same"
print_row "Gate count"     $gate_count   $gate_count   "Same/nearly same"
print_row "Internal power"  $clk_low_int  $clk_high_int  "Higher for high clock"
print_row "Switching power" $clk_low_sw   $clk_high_sw   "Higher for high clock"
print_row "Leakage power"   $clk_low_lk   $clk_high_lk   "Similar"
print_row "Total power"     $clk_low_tot  $clk_high_tot  "Higher for high clock"

puts ""

# Section B
puts "## B. Data Activity Experiment\n"
puts "Clock is fixed at 100 MHz in both VCDs.\n"
print_row "Metric" "LOW DATA" "HIGH DATA" "Expected"
puts "|-------------------|--------------------------|--------------------------|-------------------------|"
print_row "Cell area"      $cell_area    $cell_area    "Same/nearly same"
print_row "Gate count"     $gate_count   $gate_count   "Same/nearly same"
print_row "Internal power"  $data_low_int  $data_high_int  "Higher for high data"
print_row "Switching power" $data_low_sw   $data_high_sw   "Higher for high data"
print_row "Leakage power"   $data_low_lk   $data_high_lk   "Similar"
print_row "Total power"     $data_low_tot  $data_high_tot  "Higher for high data"
