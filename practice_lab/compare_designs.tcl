#!/usrVar/bin/env wish
# ==============================================================================
# Script: compare_innovus_designs.tcl
# Description: Post-route Innovus PnR signoff report parser.
#              Parses Total Power, Area (main), Setup/Hold WNS, Fmax & Deltas.
# ==============================================================================

package require Tk

# ------------------------------------------------------------------------------
# Safe Re-sourcing Cleanup
# ------------------------------------------------------------------------------
foreach w [winfo children .] {
    catch {destroy $w}
}

foreach f {HeaderFont TitleFont CellFont BoldCell OverheadCell} {
    if {[lsearch -exact [font names] $f] != -1} {
        catch {font delete $f}
    }
}

# ------------------------------------------------------------------------------
# GUI Window Setup & Fonts
# ------------------------------------------------------------------------------
wm title . "Innovus PnR Signoff PPA Comparison (Normal vs. Pipelined)"
wm geometry . "1000x580"
wm resizable . 1 1
. configure -bg "#f8fafc"

font create HeaderFont   -family "Helvetica" -size 11 -weight bold
font create TitleFont    -family "Helvetica" -size 14 -weight bold
font create CellFont     -family "Helvetica" -size 10
font create BoldCell     -family "Helvetica" -size 10 -weight bold
font create OverheadCell -family "Helvetica" -size 10 -weight bold -slant italic

# ------------------------------------------------------------------------------
# Helper Procedures
# ------------------------------------------------------------------------------
proc open_report_file {file_path} {
    if {[string match "*.gz" $file_path]} {
        return [open "| gzip -dc \"$file_path\"" r]
    } else {
        return [open $file_path r]
    }
}

proc resolve_dir {dir_name} {
    if {[file isdirectory $dir_name]} { return $dir_name }
    set matches [glob -nocomplain -types d "*${dir_name}*"]
    if {[llength $matches] > 0} { return [lindex $matches 0] }
    return $dir_name
}

# ------------------------------------------------------------------------------
# Parse Signoff Metrics
# ------------------------------------------------------------------------------
proc parse_design_metrics {raw_dir} {
    set dir [resolve_dir $raw_dir]

    set area "N/A"
    set power "N/A"
    set setup_wns "N/A"
    set setup_tns "N/A"
    set hold_wns "N/A"
    set hold_tns "N/A"
    set clock_period 10.0; # Default fallback 10ns

    set raw_area -1.0
    set raw_power -1.0
    set raw_setup_wns -999.0

    if {![file isdirectory $dir]} {
        return [list $area $power $setup_wns $setup_tns $hold_wns $hold_tns "DIR NOT FOUND" $raw_area $raw_power $raw_setup_wns $clock_period]
    }

    # 1. Parse Standard Cell Area ONLY from main summary reports (*.main.htm.ascii / *.main.htm)
    set area_files [glob -nocomplain \
        [file join $dir "summaryReport" "*.main.htm.ascii"] \
        [file join $dir "summaryReport" "*.main.htm"] \
        [file join $dir "*.main.htm.ascii"] \
        [file join $dir "*.main.htm"]]

    foreach area_file $area_files {
        if {$area ne "N/A"} break
        if {![file isfile $area_file]} continue
        if {![catch {
            set fp [open_report_file $area_file]
            while {[gets $fp line] >= 0} {
                regsub -all {<[^>]+>} $line " " clean_line

                if {[regexp -nocase {Total\s+area\s+of\s+Standard\s+cells\s*[:|]?\s*([\d\.]+)} $clean_line -> val] ||
                    [regexp -nocase {Total\s+Cell\s+Area\s*[:|]?\s*([\d\.]+)} $clean_line -> val] ||
                    [regexp -nocase {Standard\s+Cell\s+Area\s*[:|]?\s*([\d\.]+)} $clean_line -> val] ||
                    [regexp -nocase {Total\s+area\s*[:|]?\s*([\d\.]+)} $clean_line -> val]} {
                    if {$val > 0} {
                        set raw_area $val
                        set area [format "%.2f um\u00b2" $val]
                        break
                    }
                }
            }
            close $fp
        }]} {}
    }

    # 2. Parse Power from powerReports/*.rpt (Targeting 3rd column: Total Power)
    set power_files [glob -nocomplain \
        [file join $dir "powerReports" "*.rpt"] \
        [file join $dir "power.rpt"] \
        [file join $dir "*power*.rpt"]]

    if {[llength $power_files] > 0} {
        if {![catch {
            set fp [open_report_file [lindex $power_files 0]]
            while {[gets $fp line] >= 0} {
                # Format: Total ( <count> of <count> ) <Internal> <Switching> <Total> <Leakage>
                if {[regexp -nocase {^\s*Total\s*(?:\([^)]*\))?\s+[\d\.eE+-]+\s+[\d\.eE+-]+\s+([\d\.eE+-]+)} $line -> val] ||
                    [regexp -nocase {Total\s+(?:Design\s+)?Power\s*[:=]?\s*([\d\.]+)} $line -> val]} {
                    set raw_power $val
                    set power [format "%.4f mW" $val]
                    break
                }
            }
            close $fp
        }]} {}
    }

    # 3. Parse Target Clock Period from SDC constraints
    set sdc_files [glob -nocomplain \
        [file join $dir "output" "constraints" "*.sdc"] \
        [file join $dir "*.sdc"]]
    if {[llength $sdc_files] > 0} {
        if {![catch {
            set fp [open [lindex $sdc_files 0] r]
            while {[gets $fp line] >= 0} {
                if {[regexp -nocase {create_clock.*-period\s+([\d\.]+)} $line -> p_val]} {
                    set clock_period $p_val
                    break
                }
            }
            close $fp
        }]} {}
    }

    # 4. Parse Setup Timing from timingReports/*postRoute.summary (.gz)
    set setup_files [glob -nocomplain \
        [file join $dir "timingReports" "*postRoute.summary"] \
        [file join $dir "timingReports" "*postRoute.summary.gz"] \
        [file join $dir "*postRoute.summary*"]]

    set valid_setup_files [list]
    foreach f $setup_files {
        if {![string match "*hold*" $f]} { lappend valid_setup_files $f }
    }

    if {[llength $valid_setup_files] > 0} {
        if {![catch {
            set fp [open_report_file [lindex $valid_setup_files 0]]
            while {[gets $fp line] >= 0} {
                if {[regexp -nocase {WNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val] ||
                    [regexp -nocase {WNS\s*:\s*([-\d\.]+)} $line -> val]} {
                    set raw_setup_wns $val
                    set setup_wns [format "%.3f ns" $val]
                }
                if {[regexp -nocase {TNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val] ||
                    [regexp -nocase {TNS\s*:\s*\|\s*([-\d\.]+)} $line -> val]} {
                    set setup_tns [format "%.3f ns" $val]
                }
            }
            close $fp
        }]} {}
    }

    # 5. Parse Hold Timing from timingReports/*postRoute_hold.summary (.gz)
    set hold_files [glob -nocomplain \
        [file join $dir "timingReports" "*postRoute_hold.summary"] \
        [file join $dir "timingReports" "*postRoute_hold.summary.gz"] \
        [file join $dir "*postRoute_hold.summary*"]]

    if {[llength $hold_files] > 0} {
        if {![catch {
            set fp [open_report_file [lindex $hold_files 0]]
            while {[gets $fp line] >= 0} {
                if {[regexp -nocase {WNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val] ||
                    [regexp -nocase {WNS\s*:\s*([-\d\.]+)} $line -> val]} {
                    set hold_wns [format "%.3f ns" $val]
                }
                if {[regexp -nocase {TNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val] ||
                    [regexp -nocase {TNS\s*:\s*\|\s*([-\d\.]+)} $line -> val]} {
                    set hold_tns [format "%.3f ns" $val]
                }
            }
            close $fp
        }]} {}
    }

    # Signoff Timing Status
    set status "N/A"
    if {$setup_wns ne "N/A"} {
        scan $setup_wns "%f" s_val
        if {$s_val >= 0.0} { set status "PASSED" } else { set status "VIOLATED" }
    }

    return [list $area $power $setup_wns $setup_tns $hold_wns $hold_tns $status $raw_area $raw_power $raw_setup_wns $clock_period]
}

# ------------------------------------------------------------------------------
# Build GUI Table Layout
# ------------------------------------------------------------------------------

frame .header -bg "#0f172a"
pack .header -fill x

label .header.title -text "Innovus Signoff PPA Metrics: Fmax & Timing Analysis" \
    -font TitleFont -fg "#ffffff" -bg "#0f172a" -padx 15 -pady 8
pack .header.title -anchor w

frame .table -bg "#ffffff" -bd 1 -relief solid
pack .table -fill x -padx 20 -pady 15

set headers [list "Signoff Metric" "Normal (add_normal)" "Pipelined (add_pipelined)" "Pipelined Delta / Speedup"]
for {set col 0} {$col < [llength $headers]} {incr col} {
    label .table.h_$col -text [lindex $headers $col] -font HeaderFont \
        -bg "#f1f5f9" -fg "#0f172a" -padx 12 -pady 8 -anchor w -bd 1 -relief groove
    grid .table.h_$col -row 0 -column $col -sticky ew
}

# Extract metrics
set m_norm [parse_design_metrics "normal"]
set m_pipe [parse_design_metrics "pipelined"]

# Extract Raw Metrics
set norm_area [lindex $m_norm 7]
set pipe_area [lindex $m_pipe 7]
set norm_power [lindex $m_norm 8]
set pipe_power [lindex $m_pipe 8]

set norm_wns [lindex $m_norm 9]
set pipe_wns [lindex $m_pipe 9]
set norm_tclk [lindex $m_norm 10]
set pipe_tclk [lindex $m_pipe 10]

# Compute Timing Metrics (T_crit, Fmax)
set norm_tcrit [expr {$norm_tclk - $norm_wns}]
set pipe_tcrit [expr {$pipe_tclk - $pipe_wns}]

set norm_fmax [expr {1000.0 / $norm_tcrit}]
set pipe_fmax [expr {1000.0 / $pipe_tcrit}]

# Formatted strings
set str_norm_tcrit [format "%.3f ns" $norm_tcrit]
set str_pipe_tcrit [format "%.3f ns" $pipe_tcrit]

set str_norm_fmax [format "%.2f MHz" $norm_fmax]
set str_pipe_fmax [format "%.2f MHz" $pipe_fmax]

# Calculate Deltas
set delta_area "N/A"
if {$norm_area > 0 && $pipe_area > 0} {
    set pct [expr {(($pipe_area - $norm_area) / $norm_area) * 100.0}]
    set delta_area [format "%+.2f%% Area Overhead" $pct]
}

set delta_power "N/A"
if {$norm_power > 0 && $pipe_power > 0} {
    set pct [expr {(($pipe_power - $norm_power) / $norm_power) * 100.0}]
    set delta_power [format "%+.2f%% Power Overhead" $pct]
}

set delta_wns [format "%+.3f ns Slack Gain" [expr {$pipe_wns - $norm_wns}]]
set delta_tcrit [format "%+.2f%% Delay Reduction" [expr {(($pipe_tcrit - $norm_tcrit) / $norm_tcrit) * 100.0}]]

set fmax_gain [expr {(($pipe_fmax - $norm_fmax) / $norm_fmax) * 100.0}]
set delta_fmax [format "%+.2f%% Fmax Increase" $fmax_gain]

# Calculate Hold WNS Reduction
set delta_hold_wns "-"
set norm_hold_str [lindex $m_norm 4]
set pipe_hold_str [lindex $m_pipe 4]
if {$norm_hold_str ne "N/A" && $pipe_hold_str ne "N/A"} {
    scan $norm_hold_str "%f" nhw
    scan $pipe_hold_str "%f" phw
    set h_diff [expr {$phw - $nhw}]
    set delta_hold_wns [format "%+.3f ns Reduced Margin" $h_diff]
}

# Row List Definitions
set display_rows [list \
    [list "Standard Cell Area"          [lindex $m_norm 0] [lindex $m_pipe 0] $delta_area] \
    [list "Total Power (power.rpt)"    [lindex $m_norm 1] [lindex $m_pipe 1] $delta_power] \
    [list "Setup WNS (postRoute)"       [lindex $m_norm 2] [lindex $m_pipe 2] $delta_wns] \
    [list "Critical Path Delay (Tcrit)" $str_norm_tcrit    $str_pipe_tcrit    $delta_tcrit] \
    [list "Max Frequency (Fmax)"        $str_norm_fmax     $str_pipe_fmax     $delta_fmax] \
    [list "Hold WNS (postRoute_hold)"   [lindex $m_norm 4] [lindex $m_pipe 4] $delta_hold_wns] \
    [list "Signoff Timing Status"       [lindex $m_norm 6] [lindex $m_pipe 6] "-"] \
]

for {set r 0} {$r < [llength $display_rows]} {incr r} {
    set row_data [lindex $display_rows $r]
    set row_idx [expr {$r + 1}]
    set bg_color [expr {$r % 2 == 0 ? "#ffffff" : "#f8fafc"}]

    # Metric Name
    label .table.r_${r}_c0 -text [lindex $row_data 0] -font BoldCell \
        -bg $bg_color -fg "#334155" -padx 12 -pady 5 -anchor w -bd 1 -relief groove
    grid .table.r_${r}_c0 -row $row_idx -column 0 -sticky ew

    # Normal & Pipelined Values
    for {set c 1} {$c <= 2} {incr c} {
        set val [lindex $row_data $c]
        set fg_color "#0f172a"
        if {$val eq "PASSED"} { set fg_color "#16a34a" }
        if {$val eq "VIOLATED"} { set fg_color "#dc2626" }

        label .table.r_${r}_c${c} -text $val -font CellFont \
            -bg $bg_color -fg $fg_color -padx 12 -pady 5 -anchor w -bd 1 -relief groove
        grid .table.r_${r}_c${c} -row $row_idx -column $c -sticky ew
    }

    # Delta / Impact
    label .table.r_${r}_c3 -text [lindex $row_data 3] -font OverheadCell \
        -bg $bg_color -fg "#0369a1" -padx 12 -pady 5 -anchor w -bd 1 -relief groove
    grid .table.r_${r}_c3 -row $row_idx -column 3 -sticky ew
}

grid columnconfigure .table 0 -weight 2
grid columnconfigure .table 1 -weight 1
grid columnconfigure .table 2 -weight 1
grid columnconfigure .table 3 -weight 2

frame .btn_bar -bg "#f8fafc"
pack .btn_bar -fill x -padx 20 -pady {0 15}

button .btn_bar.close -text "Close Window" -command {destroy .} \
    -font BoldCell -bg "#cbd5e1" -fg "#0f172a" -padx 15 -pady 6 -bd 1
pack .btn_bar.close -side right

update
wm deiconify .
raise .
