#!/usrVar/bin/env wish
# ==============================================================================
# Script: compare_designs.tcl
# Description: Reads post-route PnR signoff reports across FIR architectures
#              and displays a Tk GUI comparison window in Cadence Genus/Innovus.
# ==============================================================================

package require Tk

# ------------------------------------------------------------------------------
# Safe Re-sourcing Cleanup
# ------------------------------------------------------------------------------
foreach w [winfo children .] {
    catch {destroy $w}
}

foreach f {HeaderFont TitleFont CellFont BoldCell} {
    if {[lsearch -exact [font names] $f] != -1} {
        catch {font delete $f}
    }
}

# ------------------------------------------------------------------------------
# Configure Main GUI Window & Fonts
# ------------------------------------------------------------------------------
wm title . "VLSI Design PnR Signoff Comparison - FIR Filter Architectures"
wm geometry . "920x440"
wm resizable . 1 1
. configure -bg "#f8fafc"

font create HeaderFont -family "Helvetica" -size 11 -weight bold
font create TitleFont  -family "Helvetica" -size 14 -weight bold
font create CellFont   -family "Helvetica" -size 10
font create BoldCell   -family "Helvetica" -size 10 -weight bold

# ------------------------------------------------------------------------------
# File Searching & Parsing Procedures
# ------------------------------------------------------------------------------

# Helper: Resolve Directory Path Variations (handles fir_piplined, fir_pipelined, etc.)
proc resolve_dir {dir_name} {
    if {[file isdirectory $dir_name]} { return $dir_name }
    
    set candidates [list \
        $dir_name \
        "${dir_name}d" \
        "fir_pipelined" \
        "fir_piplined" \
        "fir_4tap_pipelined" \
    ]
    foreach c $candidates {
        if {[file isdirectory $c]} { return $c }
    }
    
    set search_pat "*[string map {pipelined *pip* piplined *pip*} $dir_name]*"
    set matches [glob -nocomplain -types d $search_pat]
    if {[llength $matches] > 0} { return [lindex $matches 0] }

    return $dir_name
}

# Parse Signoff Metrics from Design Directory
proc parse_design_metrics {raw_dir} {
    set dir [resolve_dir $raw_dir]

    set area "N/A"
    set power "N/A"
    set setup_wns "N/A"
    set setup_tns "N/A"
    set hold_wns "N/A"
    set hold_tns "N/A"
    set status "N/A"

    if {![file isdirectory $dir]} {
        return [list $area $power $setup_wns $setup_tns $hold_wns $hold_tns "DIR NOT FOUND"]
    }

    # 1. Parse Standard Cell Area from *.main.htm.ascii inside summaryReport/
    set area_files [glob -nocomplain \
        [file join $dir "summaryReport" "*.main.htm.ascii"] \
        [file join $dir "summaryReports" "*.main.htm.ascii"] \
        [file join $dir "summaryReport" "*"] \
        [file join $dir "summaryReports" "*"] \
        [file join $dir "*.main.htm.ascii"] \
        [file join $dir "area.rpt"] \
        [file join $dir "*area*.rpt"]]

    foreach area_file $area_files {
        if {$area ne "N/A"} break
        if {![file isfile $area_file]} continue
        if {![catch {
            set fp [open $area_file r]
            while {[gets $fp line] >= 0} {
                if {[regexp -nocase {Total\s+area\s+of\s+Standard\s+cells\s*[:|]?\s*([\d\.]+)} $line -> val] ||
                    [regexp -nocase {Total\s+Cell\s+Area\s*[:|]?\s*([\d\.]+)} $line -> val] ||
                    [regexp -nocase {Standard\s+Cell\s+Area\s*[:|]?\s*([\d\.]+)} $line -> val]} {
                    set area [format "%.2f um\u00b2" $val]
                    break
                }
            }
            close $fp
        }]} {}
    }

    # 2. Parse Power from power.rpt
    set power_files [glob -nocomplain \
        [file join $dir "power.rpt"] \
        [file join $dir "*power*.rpt"]]
    if {[llength $power_files] > 0} {
        if {![catch {
            set fp [open [lindex $power_files 0] r]
            while {[gets $fp line] >= 0} {
                if {[regexp -nocase {Total\s+(?:Design\s+)?Power\s*[:=]?\s*([\d\.]+)} $line -> val] ||
                    [regexp -nocase {^\s*Total\s+.*?\s+([\d\.]+)\s*(?:mW|uW|W)?$} $line -> val]} {
                    set power [format "%.4f mW" $val]
                    break
                }
            }
            close $fp
        }]} {}
    }

    # 3. Parse Setup Timing directly from timingReports/*postRoute.summary
    set setup_files [glob -nocomplain \
        [file join $dir "timingReports" "*postRoute.summary"] \
        [file join $dir "*postRoute.summary"]]
    
    set valid_setup_files [list]
    foreach f $setup_files {
        if {![string match "*hold*" $f]} {
            lappend valid_setup_files $f
        }
    }

    if {[llength $valid_setup_files] > 0} {
        if {![catch {
            set fp [open [lindex $valid_setup_files 0] r]
            while {[gets $fp line] >= 0} {
                if {[regexp -nocase {WNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val]} {
                    set setup_wns [format "%.3f ns" $val]
                }
                if {[regexp -nocase {TNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val]} {
                    set setup_tns [format "%.3f ns" $val]
                }
            }
            close $fp
        }]} {}
    }

    # 4. Parse Hold Timing directly from timingReports/*postRoute_hold.summary
    set hold_files [glob -nocomplain \
        [file join $dir "timingReports" "*postRoute_hold.summary"] \
        [file join $dir "*postRoute_hold.summary"]]

    if {[llength $hold_files] > 0} {
        if {![catch {
            set fp [open [lindex $hold_files 0] r]
            while {[gets $fp line] >= 0} {
                if {[regexp -nocase {WNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val]} {
                    set hold_wns [format "%.3f ns" $val]
                }
                if {[regexp -nocase {TNS\s*\(ns\)\s*:\s*\|\s*([-\d\.]+)} $line -> val]} {
                    set hold_tns [format "%.3f ns" $val]
                }
            }
            close $fp
        }]} {}
    }

    # Determine Overall Signoff Timing Status
    if {$setup_wns ne "N/A" && $hold_wns ne "N/A"} {
        scan $setup_wns "%f" s_val
        scan $hold_wns "%f" h_val
        if {$s_val >= 0.0 && $h_val >= 0.0} {
            set status "PASSED"
        } else {
            set status "VIOLATED"
        }
    } elseif {$setup_wns ne "N/A"} {
        scan $setup_wns "%f" s_val
        if {$s_val >= 0.0} { set status "PASSED" } else { set status "VIOLATED" }
    }

    return [list $area $power $setup_wns $setup_tns $hold_wns $hold_tns $status]
}

# ------------------------------------------------------------------------------
# Build GUI Window Layout
# ------------------------------------------------------------------------------

# Header Banner
frame .header -bg "#0f172a"
pack .header -fill x

label .header.title -text "FIR Filter PnR Signoff Metrics & Architecture Comparison" \
    -font TitleFont -fg "#ffffff" -bg "#0f172a" -padx 15 -pady 8
pack .header.title -anchor w


# Main Metrics Table Container
frame .table -bg "#ffffff" -bd 1 -relief solid
pack .table -fill x -padx 20 -pady 15

# Column Headers
set headers [list "Signoff Metric" "Baseline (fir)" "Area Optimized" "Pipelined"]
for {set col 0} {$col < [llength $headers]} {incr col} {
    label .table.h_$col -text [lindex $headers $col] -font HeaderFont \
        -bg "#f1f5f9" -fg "#0f172a" -padx 12 -pady 8 -anchor w -bd 1 -relief groove
    grid .table.h_$col -row 0 -column $col -sticky ew
}

# Parse Metric Data Across Directories
set m_base [parse_design_metrics "fir"]
set m_area [parse_design_metrics "fir_area_optimized"]
set m_pipe [parse_design_metrics "fir_pipelined"]

# Table Row Labels
set row_labels [list \
    "Standard Cell Area" \
    "Total Power (power.rpt)" \
    "Setup WNS (postRoute.summary)" \
    "Setup TNS (postRoute.summary)" \
    "Hold WNS (postRoute_hold.summary)" \
    "Hold TNS (postRoute_hold.summary)" \
    "Signoff Timing Status" \
]

for {set r 0} {$r < [llength $row_labels]} {incr r} {
    set row_idx [expr {$r + 1}]
    set bg_color [expr {$r % 2 == 0 ? "#ffffff" : "#f8fafc"}]

    # Metric Name Column
    label .table.r_${r}_c0 -text [lindex $row_labels $r] -font BoldCell \
        -bg $bg_color -fg "#334155" -padx 12 -pady 6 -anchor w -bd 1 -relief groove
    grid .table.r_${r}_c0 -row $row_idx -column 0 -sticky ew

    # Values for Each Architecture Column
    set c 1
    foreach m_data [list $m_base $m_area $m_pipe] {
        set val [lindex $m_data $r]
        set fg_color "#0f172a"

        if {$val eq "PASSED"} {
            set fg_color "#16a34a"
        } elseif {$val eq "VIOLATED"} {
            set fg_color "#dc2626"
        } elseif {$val eq "DIR NOT FOUND"} {
            set fg_color "#94a3b8"
        }

        label .table.r_${r}_c${c} -text $val -font CellFont \
            -bg $bg_color -fg $fg_color -padx 12 -pady 6 -anchor w -bd 1 -relief groove
        grid .table.r_${r}_c${c} -row $row_idx -column $c -sticky ew
        incr c
    }
}

# Responsive Column Stretching
grid columnconfigure .table 0 -weight 2
grid columnconfigure .table 1 -weight 1
grid columnconfigure .table 2 -weight 1
grid columnconfigure .table 3 -weight 1

# Bottom Action Bar
frame .btn_bar -bg "#f8fafc"
pack .btn_bar -fill x -padx 20 -pady {0 15}

button .btn_bar.close -text "Close Window" -command {destroy .} \
    -font BoldCell -bg "#cbd5e1" -fg "#0f172a" -padx 15 -pady 6 -bd 1

pack .btn_bar.close -side right

# Force Window Display Refresh
update
wm deiconify .
raise .
