# ==============================================================================
# Pure TCL Master Synthesis Runner & Multi-Node QoR Aggregator
# ==============================================================================

package require Tk

set root_dir [pwd]

# Define matrix dimensions
set designs {"fir" "fir_area_optimized" "fir_pipelined"}
set nodes   {"45nm" "90nm" "180nm"}
set corners {"slow" "fast" "typical"}

# Script name mapping per design
array set script_names {
    "fir"                "fir_4taps.tcl"
    "fir_area_optimized" "fir_4tap_shared_mult.tcl"
    "fir_pipelined"      "fir_4tap_pipelined.tcl"
}

# Build execution list dynamically
set script_list {}
foreach d $designs {
    foreach n $nodes {
        foreach c $corners {
            set s_path "./$d/$n/$c/$script_names($d)"
            if {[file exists $s_path]} {
                lappend script_list $s_path
            }
        }
    }
}

set comparison_data {}

# Multi-report QoR parser procedure
proc parse_qor_metrics {reports_dir} {
    set area "N/A"
    set power "N/A"
    set gates "N/A"
    set slack "N/A"

    set rpt_files [glob -nocomplain "$reports_dir/*.rpt"]

    foreach f $rpt_files {
        if {![file isfile $f]} continue
        set fp [open $f r]
        set content [read $fp]
        close $fp

        # 1. Timing Slack (Handles "Slack: = 0.5", "Worst Slack: -0.12", "Slack: 1.23", "unconstrained")
        if {$slack eq "N/A"} {
            if {[regexp -nocase {Worst\s+Slack\s*[:=]?\s*=?\s*(-?[0-9]+\.?[0-9]*(?:[eE][+-]?[0-9]+)?)} $content -> val]} {
                set slack [format "%.3f" $val]
            } elseif {[regexp -nocase {Slack\s*[:=]\s*=?\s*(-?[0-9]+\.?[0-9]*(?:[eE][+-]?[0-9]+)?)} $content -> val]} {
                set slack [format "%.3f" $val]
            } elseif {[regexp -nocase {no timing paths|unconstrained} $content]} {
                set slack "unconst"
            }
        }

        # 2. Area
        if {$area eq "N/A"} {
            if {[regexp -nocase {Total Area\s*:\s*([0-9\.]+)} $content -> val]} {
                set area [format "%.2f" $val]
            } elseif {[regexp -nocase {Cell Area\s*:\s*([0-9\.]+)} $content -> val]} {
                set area [format "%.2f" $val]
            } elseif {[regexp {([0-9]+\.[0-9]+)\s+<none>} $content -> val]} {
                set area [format "%.2f" $val]
            }
        }

        # 3. Power (Filters operating conditions like 100.0 C / 100.0 MHz)
        if {$power eq "N/A"} {
            if {[regexp -nocase {Total Power\s*:\s*([0-9eE.+-]+)} $content -> val]} {
                set power $val
            } else {
                foreach line [split $content "\n"] {
                    if {[regexp -nocase {deg|C|MHz|Voltage|Condition} $line]} continue

                    if {[regexp -nocase {Subtotal\s+[\d\.eE\+\-]+\s+[\d\.eE\+\-]+\s+[\d\.eE\+\-]+\s+([\d\.eE\+\-]+)} $line -> val]} {
                        set power $val
                        break
                    } elseif {[regexp -nocase {Total\s+[\d\.eE\+\-]+\s+[\d\.eE\+\-]+\s+[\d\.eE\+\-]+\s+([\d\.eE\+\-]+)} $line -> val]} {
                        set power $val
                        break
                    } elseif {[regexp -nocase {Total\s+.*?\s+([\d\.eE\+\-]+)\s*(?:nW|uW|mW|W)} $line -> val]} {
                        set power $val
                        break
                    }
                }
            }
        }

        # 4. Gate / Instance Count (Handles key-value & Genus area table rows)
        if {$gates eq "N/A"} {
            if {[regexp -nocase {(?:Leaf\s+)?Instance[s]?\s*(?:Count)?\s*[:=]\s*([0-9]+)} $content -> val]} {
                set gates $val
            } elseif {[regexp -nocase {Cell[s]?\s*(?:Count)?\s*[:=]\s*([0-9]+)} $content -> val]} {
                set gates $val
            } elseif {[regexp -nocase {Gate[s]?\s*(?:Count)?\s*[:=]\s*([0-9]+)} $content -> val]} {
                set gates $val
            } elseif {[regexp -nocase {total\s+([0-9]+)\s+instances} $content -> val]} {
                set gates $val
            } else {
                foreach line [split $content "\n"] {
                    if {[regexp {^\s*[a-zA-Z0-9_\-/]+\s+([0-9]+)\s+[0-9]+\.[0-9]+} $line -> cnt]} {
                        if {$cnt > 0} {
                            set gates $cnt
                            break
                        }
                    } elseif {[regexp {^\s*[a-zA-Z0-9_\-/]+\s+\S+\s+([0-9]+)\s+[0-9]+\.[0-9]+} $line -> cnt]} {
                        if {$cnt > 0} {
                            set gates $cnt
                            break
                        }
                    }
                }
            }
        }
    }

    return [list $area $power $gates $slack]
}

# ==============================================================================
# Synthesis Execution Loop
# ==============================================================================
foreach script $script_list {
    set script_dir [file dirname $script]
    set script_file [file tail $script]

    set path_parts [split $script "/"]
    set module_dir [lindex $path_parts 1]
    set tech_node  [lindex $path_parts 2]
    set lib_corner [lindex $path_parts 3]

    puts "\n========================================================="
    puts " Synthesizing: $module_dir | $tech_node | Corner: $lib_corner"
    puts "========================================================="

    if {[file exists $script]} {
        cd $script_dir
        file mkdir output/netlist output/constraints output/reports

        # Read script and patch search path dynamically to include root design dir
        set fp [open $script_file r]
        set s_content [read $fp]
        close $fp

        regsub -all {set_db\s+init_hdl_search_path\s+[^\n]+} $s_content "set_db init_hdl_search_path \[list . .. ../.. $root_dir/$module_dir\]" s_content_fixed

        set fp [open "temp_run.tcl" w]
        puts $fp $s_content_fixed
        close $fp

        # Run isolated sub-process
        catch { exec genus -batch -files temp_run.tcl } build_log

        # Parse metrics
        set metrics [parse_qor_metrics "output/reports"]
        set area  [lindex $metrics 0]
        set power [lindex $metrics 1]
        set gates [lindex $metrics 2]
        set slack [lindex $metrics 3]

        lappend comparison_data [list $module_dir $tech_node $lib_corner $area $power $gates $slack]

        catch { file delete -force temp_run.tcl }
        cd $root_dir
    } else {
        puts "ERROR: Script $script not found!"
        cd $root_dir
    }
}

# ==============================================================================
# Terminal Table Output
# ==============================================================================
puts "\n===================================================================================================="
puts [format "%-22s %-10s %-10s %-12s %-14s %-12s %-10s" "Design Directory" "Node" "Corner" "Area (um^2)" "Power" "Gate Count" "Slack (ns)"]
puts "===================================================================================================="
foreach row $comparison_data {
    puts [format "%-22s %-10s %-10s %-12s %-14s %-12s %-10s" [lindex $row 0] [lindex $row 1] [lindex $row 2] [lindex $row 3] [lindex $row 4] [lindex $row 5] [lindex $row 6]]
}
puts "====================================================================================================\n"

# ==============================================================================
# Scrollable Tk GUI Window
# ==============================================================================
if {[winfo exists .summary]} { destroy .summary }
toplevel .summary
wm title .summary "QoR Multi-Node Synthesis Comparison - FIR Lab"
wm geometry .summary "980x600"
.summary configure -bg white

# Scrollable canvas setup for 27+ rows
canvas .summary.c -bg white -yscrollcommand ".summary.s set"
scrollbar .summary.s -orient vertical -command ".summary.c yview"
frame .summary.f -bg white

.summary.c create window 0 0 -window .summary.f -anchor nw

bind .summary.f <Configure> {
    .summary.c configure -scrollregion [.summary.c bbox all]
}

pack .summary.s -side right -fill y
pack .summary.c -side left -fill both -expand true

set headers {"Design Folder" "Tech Node" "Library" "Area (um^2)" "Power" "Gate Count" "Slack (ns)"}
set col 0
foreach h $headers {
    label .summary.f.h$col -text $h -font {Helvetica 11 bold} -bg "#0047AB" -fg white -width 15 -pady 5
    grid .summary.f.h$col -row 0 -column $col -sticky nsew -padx 1 -pady 1
    incr col
}

set r 1
foreach data $comparison_data {
    set col 0
    set bg_color [expr {$r % 2 == 0 ? "#E8F0FE" : "#FFFFFF"}]
    foreach val $data {
        label .summary.f.r${r}c${col} -text $val -font {Helvetica 10} -bg $bg_color -pady 4
        grid .summary.f.r${r}c${col} -row $r -column $col -sticky nsew -padx 1 -pady 1
        incr col
    }
    incr r
}

button .summary.f.close -text "Close Comparison" -command {destroy .summary} -font {Helvetica 10 bold} -bg "#CC0000" -fg white
grid .summary.f.close -row $r -column 0 -columnspan [llength $headers] -pady 12
update
