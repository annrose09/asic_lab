###########################################################################
#               UNIVERSAL CADENCE GENUS SYNTHESIS SCRIPT
#
# Edit ONLY the variables in the PROJECT CONFIGURATION section.
# Everything else automatically uses those paths.
###########################################################################

###############################
# PROJECT CONFIGURATION
###############################

# Root directory of the project
set PROJECT_DIR "/home/vlsi52/24bvd1013/lab3/genus_structural_synthesis_labs/lab1_adder4_structural"

# Design name (Top Module)
set TOP_MODULE "adder4_structural"

# Library location
set LIB_DIR "/home/install/FOUNDRY/digital/90nm/dig/lib"

# Library file
set LIB_FILE "slow.lib"

# RTL directory
set RTL_DIR "$PROJECT_DIR/rtl"

# Constraint directory
set CONSTRAINT_DIR "$PROJECT_DIR/constraints"

# Output directory
set OUTPUT_DIR "$PROJECT_DIR/outputs"

# Report directory
set REPORT_DIR "$OUTPUT_DIR/reports"

# Netlist directory
set NETLIST_DIR "$OUTPUT_DIR/netlist"

# Output SDC directory
set OUTPUT_SDC_DIR "$OUTPUT_DIR/constraints"

# Log Directory
set LOG_DIR "$OUTPUT_DIR/logs"

# VCD File (Optional)
set VCD_FILE "$OUTPUT_DIR/adder4.vcd"

# Constraint file
set SDC_FILE "$CONSTRAINT_DIR/adder4_constraints.sdc"

# RTL files
set RTL_FILES {
    full_adder.v
    adder4_structural.v
}


###############################
# CREATE OUTPUT DIRECTORIES
###############################

file mkdir $OUTPUT_DIR
file mkdir $REPORT_DIR
file mkdir $NETLIST_DIR
file mkdir $OUTPUT_SDC_DIR
file mkdir $LOG_DIR

###############################
# HELPER PROCEDURE FOR REPORTS
###############################

proc generate_stage_reports {stage_name report_dir top_module} {
    report_timing > "$report_dir/${top_module}_${stage_name}_timing.rpt"
    report_area   > "$report_dir/${top_module}_${stage_name}_area.rpt"
    report_gates  > "$report_dir/${top_module}_${stage_name}_gates.rpt"
    report_power  > "$report_dir/${top_module}_${stage_name}_power.rpt"
    report_qor    > "$report_dir/${top_module}_${stage_name}_qor.rpt"
}

###############################
# SEARCH PATHS
###############################

set_db init_lib_search_path $LIB_DIR
set_db init_hdl_search_path $RTL_DIR

###############################
# READ LIBRARY
###############################

read_libs $LIB_FILE

###############################
# READ RTL
###############################

read_hdl $RTL_FILES

###############################
# ELABORATE DESIGN
###############################

elaborate $TOP_MODULE

###############################
# CLOCK
###############################

# Virtual clock (for combinational designs)

create_clock -name VIRTUAL_CLK -period 10.0

###############################
# READ CONSTRAINTS
###############################

read_sdc $SDC_FILE

###############################
# OPTIONAL VCD ACTIVITY
###############################

if {[file exists $VCD_FILE]} {

    puts ""
    puts "------------------------------------------"
    puts "Reading Switching Activity"
    puts "$VCD_FILE"
    puts "------------------------------------------"

    read_vcd $VCD_FILE

} else {

    puts ""
    puts "------------------------------------------"
    puts "WARNING : VCD File Not Found"
    puts "Using Vectorless Power Estimation"
    puts "------------------------------------------"

}

###############################
# SYNTHESIS SETTINGS
###############################

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

###############################
# DESIGN CHECKS
###############################

check_design -unresolved \
> "$REPORT_DIR/${TOP_MODULE}_check_design.rpt"

###############################
# STAGE 1: GENERIC SYNTHESIS
###############################

syn_generic

# Save Generic Netlist
write_hdl > "$NETLIST_DIR/${TOP_MODULE}_generic.v"

# Save Generic Reports
generate_stage_reports "generic" $REPORT_DIR $TOP_MODULE

###############################
# STAGE 2: TECHNOLOGY MAPPING
###############################

syn_map

# Save Mapped Netlist
write_hdl > "$NETLIST_DIR/${TOP_MODULE}_mapped.v"

# Save Mapped Reports
generate_stage_reports "mapped" $REPORT_DIR $TOP_MODULE

###############################
# STAGE 3: OPTIMIZATION
###############################

syn_opt

# Save Optimized Netlist
write_hdl > "$NETLIST_DIR/${TOP_MODULE}_opt.v"

# Save Output SDC
write_sdc > "$OUTPUT_SDC_DIR/${TOP_MODULE}_output_constraints.sdc"

# Save Optimized Reports
generate_stage_reports "opt" $REPORT_DIR $TOP_MODULE

###############################
# SUMMARY
###############################

puts ""
puts "==========================================================="
puts "        CADENCE GENUS SYNTHESIS COMPLETED"
puts "==========================================================="
puts " Top Module   : $TOP_MODULE"
puts " Project      : $PROJECT_DIR"
puts " RTL Folder   : $RTL_DIR"
puts " Constraints  : $CONSTRAINT_DIR"
puts " Reports      : $REPORT_DIR"
puts " Netlists     : $NETLIST_DIR"
puts " Library      : $LIB_FILE"
puts "==========================================================="
puts " Generated Netlists:"
puts "   - $NETLIST_DIR/${TOP_MODULE}_generic.v"
puts "   - $NETLIST_DIR/${TOP_MODULE}_mapped.v"
puts "   - $NETLIST_DIR/${TOP_MODULE}_opt.v"
puts " Generated Report Sets (generic / mapped / opt):"
puts "   - timing, area, gates, power, qor"
puts "==========================================================="

# exit

###############################
# COMPARISON MATRIX & GUI WINDOW
###############################

proc parse_qor_rpt {file} {
    set wns "N/A"; set tns "N/A"; set cells "N/A"
    if {[file exists $file]} {
        set fp [open $file r]
        set in_cost_table 0
        while {[gets $fp line] >= 0} {
            set line [string trim $line]
            
            # Detect Cost Group header block (matches multi-line headers)
            if {[string match "*Group*" $line] || [string match "*Slack*" $line] || [string match "*Cost*" $line]} {
                if {[string match "*Slack*" $line] || [string match "*Group*" $line]} {
                    set in_cost_table 1
                    continue
                }
            }
            
            # Parse table data rows (e.g., "CLK 7457.6 0.0 0")
            if {$in_cost_table} {
                if {[string match "---*" $line] || $line eq "" || [string match "*Path Slack*" $line] || [string match "*Group*" $line]} { 
                    continue 
                }
                if {[string match "Total*" $line] || [string match "*Instance Count*" $line]} {
                    set in_cost_table 0
                } else {
                    set fields [regexp -inline -all -- {\S+} $line]
                    if {[llength $fields] >= 3} {
                        set w_val [lindex $fields 1]
                        set t_val [lindex $fields 2]
                        if {[string is double -strict $w_val]} {
                            set wns "${w_val} ps"
                            set tns "${t_val} ps"
                            set in_cost_table 0
                        }
                    }
                }
            }

            # Fallback key-value pattern matching
            if {$wns eq "N/A"} {
                if {[regexp -nocase {Worst\s+(?:Negative\s+)?Slack[^\n:]*:\s*([-\d\.\+eE]+)} $line -> val]} {
                    set wns "${val} ps"
                } elseif {[regexp -nocase {Critical\s+Path\s+Slack[^\n:]*:\s*([-\d\.\+eE]+)} $line -> val]} {
                    set wns "${val} ps"
                }
            }
            if {$tns eq "N/A"} {
                if {[regexp -nocase {Total\s+(?:Negative\s+)?Slack[^\n:]*:\s*([-\d\.\+eE]+)} $line -> val]} {
                    set tns "${val} ps"
                }
            }

            # Extract Leaf Instance Count
            if {[regexp -nocase {Leaf\s+Instance\s+Count\s+(\d+)} $line -> val]} {
                set cells $val
            } elseif {[regexp -nocase {(?:Cell|Instance)\s+Count\s*[:\s]\s*(\d+)} $line -> val] && $cells eq "N/A"} {
                set cells $val
            }
        }
        close $fp
    }
    return [list $wns $tns $cells]
}

proc parse_gates_rpt {file} {
    set gates "N/A"
    if {[file exists $file]} {
        set fp [open $file r]
        while {[gets $fp line] >= 0} {
            set line [string trim $line]
            if {[regexp -nocase {^total\s+.*\s+(\d+)\s*$} $line -> val]} {
                set gates $val
            } elseif {[regexp -nocase {^total\s+(\d+)} $line -> val]} {
                set gates $val
            }
        }
        close $fp
    }
    return $gates
}

proc parse_timing_rpt {file} {
    set delay "N/A"
    if {[file exists $file]} {
        set fp [open $file r]
        while {[gets $fp line] >= 0} {
            set line [string trim $line]
            # Strip leading non-digits (like '-' or '=') to cleanly extract numerical delay
            if {[regexp -nocase {Data\s+Path\s*:\s*[-=\s]*([\d\.]+)} $line -> val]} {
                set delay "${val} ps"
                break
            } elseif {[regexp -nocase {data\s+arrival\s+time\s*[:=]?\s*[-=\s]*([\d\.]+)} $line -> val]} {
                set delay "${val} ps"
                break
            } elseif {[regexp -nocase {Arrival\s+Time\s*[:=]?\s*[-=\s]*([\d\.]+)} $line -> val] && $delay eq "N/A"} {
                set delay "${val} ps"
            }
        }
        close $fp
    }
    return $delay
}

proc parse_area_rpt {file top_module} {
    set area "N/A"
    if {[file exists $file]} {
        set fp [open $file r]
        while {[gets $fp line] >= 0} {
            set line [string trim $line]
            if {$line eq "" || [string match "---*" $line] || [string match "Instance*" $line] || [string match "(*" $line]} { continue }
            set fields [regexp -inline -all -- {\S+} $line]
            if {[llength $fields] >= 2} {
                set first [lindex $fields 0]
                if {$first eq $top_module || [string tolower $first] eq "total"} {
                    set nums {}
                    foreach f $fields {
                        if {[string is double -strict $f]} { lappend nums $f }
                    }
                    if {[llength $nums] > 0} {
                        set area [lindex $nums end]
                    }
                }
            }
        }
        close $fp
    }
    return $area
}

proc parse_power_rpt {file} {
    set power "N/A"
    set unit "W"
    if {[file exists $file]} {
        set fp [open $file r]
        while {[gets $fp line] >= 0} {
            set line [string trim $line]
            
            # Detect unit from header
            if {[regexp -nocase {Power\s+Unit\s*:\s*(\S+)} $line -> u]} {
                set unit $u
            }
            
            # Parse Subtotal row: Subtotal <leakage> <internal> <switching> <total> <row%>
            if {[string match "Subtotal*" $line]} {
                set fields [regexp -inline -all -- {\S+} $line]
                if {[llength $fields] >= 5} {
                    set total_val [lindex $fields 4]
                    if {[string is double -strict $total_val]} {
                        if {[string tolower $unit] eq "w"} {
                            # Convert Watts to microWatts (uW) for readable display
                            set uw_val [expr {$total_val * 1e6}]
                            set power [format "%.2f uW" $uw_val]
                        } else {
                            set power "${total_val} ${unit}"
                        }
                    }
                }
            }
            
            # Fallback for key-value format "Total Power: <val>"
            if {$power eq "N/A"} {
                if {[regexp -nocase {Total\s+Power\s*:\s*([^\n]+)} $line -> val]} {
                    set power [string trim $val]
                }
            }
        }
        close $fp
    }
    return $power
}

proc generate_stage_comparison {top_module report_dir} {
    set stages {generic mapped opt}
    array set metrics {}

    foreach stage $stages {
        set qor_rpt    "$report_dir/${top_module}_${stage}_qor.rpt"
        set timing_rpt "$report_dir/${top_module}_${stage}_timing.rpt"
        set area_rpt   "$report_dir/${top_module}_${stage}_area.rpt"
        set power_rpt  "$report_dir/${top_module}_${stage}_power.rpt"
        set gates_rpt  "$report_dir/${top_module}_${stage}_gates.rpt"

        lassign [parse_qor_rpt $qor_rpt] metrics($stage,wns) metrics($stage,tns) metrics($stage,gates)
        
        # Fallback to gates report if cell count wasn't in QoR
        if {$metrics($stage,gates) eq "N/A"} {
            set metrics($stage,gates) [parse_gates_rpt $gates_rpt]
        }

        set metrics($stage,delay) [parse_timing_rpt $timing_rpt]
        set metrics($stage,area)  [parse_area_rpt $area_rpt $top_module]
        set metrics($stage,power) [parse_power_rpt $power_rpt]
    }

    # 1. TERMINAL & LOG TABLE OUTPUT
    puts ""
    puts "=========================================================================="
    puts "             SYNTHESIS STAGE COMPARISON MATRIX ($top_module)"
    puts "=========================================================================="
    puts [format "%-22s | %-15s | %-15s | %-15s" "Metric" "Generic" "Mapped" "Optimized"]
    puts "--------------------------------------------------------------------------"
    puts [format "%-22s | %-15s | %-15s | %-15s" "Worst Slack (WNS)" $metrics(generic,wns) $metrics(mapped,wns) $metrics(opt,wns)]
    puts [format "%-22s | %-15s | %-15s | %-15s" "Total Slack (TNS)" $metrics(generic,tns) $metrics(mapped,tns) $metrics(opt,tns)]
    puts [format "%-22s | %-15s | %-15s | %-15s" "Data Path Delay" $metrics(generic,delay) $metrics(mapped,delay) $metrics(opt,delay)]
    puts [format "%-22s | %-15s | %-15s | %-15s" "Total Area" $metrics(generic,area) $metrics(mapped,area) $metrics(opt,area)]
    puts [format "%-22s | %-15s | %-15s | %-15s" "Gate / Cell Count" $metrics(generic,gates) $metrics(mapped,gates) $metrics(opt,gates)]
    puts [format "%-22s | %-15s | %-15s | %-15s" "Total Power" $metrics(generic,power) $metrics(mapped,power) $metrics(opt,power)]
    puts "=========================================================================="
    puts ""

    # 2. NATIVE TK GRID TABLE GUI WINDOW
    if {![catch {package require Tk}]} {
        catch {destroy .cmp_win}
        set win [toplevel .cmp_win]
        wm title $win "Synthesis Stage Comparison Matrix - $top_module"
        wm geometry $win "720x320"
        $win configure -bg "#f8fafc"

        label $win.title -text "Synthesis Stage Comparison ($top_module)" \
            -font {Helvetica 11 bold} -bg "#f8fafc" -fg "#0f172a" -pady 8
        pack $win.title -side top -fill x

        set tbl [frame $win.tbl -bg "#cbd5e1" -bd 1 -relief solid]
        pack $tbl -expand yes -fill both -padx 12 -pady 8

        set headers [list "Metric" "Generic Stage" "Mapped Stage" "Optimized Stage"]
        set col 0
        foreach h $headers {
            label $tbl.h_$col -text $h -font {Helvetica 10 bold} \
                -bg "#1e293b" -fg "#ffffff" -padx 10 -pady 6 -anchor center
            grid $tbl.h_$col -row 0 -column $col -sticky nsew -padx 1 -pady 1
            grid columnconfigure $tbl $col -weight 1
            incr col
        }

        set row_data [list \
            [list "Worst Slack (WNS)" $metrics(generic,wns) $metrics(mapped,wns) $metrics(opt,wns)] \
            [list "Total Slack (TNS)" $metrics(generic,tns) $metrics(mapped,tns) $metrics(opt,tns)] \
            [list "Data Path Delay" $metrics(generic,delay) $metrics(mapped,delay) $metrics(opt,delay)] \
            [list "Total Area" $metrics(generic,area) $metrics(mapped,area) $metrics(opt,area)] \
            [list "Gate / Cell Count" $metrics(generic,gates) $metrics(mapped,gates) $metrics(opt,gates)] \
            [list "Total Power" $metrics(generic,power) $metrics(mapped,power) $metrics(opt,power)] \
        ]

        set r 1
        foreach row $row_data {
            set bg_color [expr {$r % 2 == 1 ? "#ffffff" : "#f1f5f9"}]
            set c 0
            foreach val $row {
                set anchor_dir [expr {$c == 0 ? "w" : "center"}]
                set font_style [expr {$c == 0 ? "{Helvetica 9 bold}" : "{Helvetica 9}"}]
                label $tbl.cell_${r}_${c} -text $val -font $font_style \
                    -bg $bg_color -fg "#0f172a" -padx 8 -pady 5 -anchor $anchor_dir
                grid $tbl.cell_${r}_${c} -row $r -column $c -sticky nsew -padx 1 -pady 1
                incr c
            }
            grid rowconfigure $tbl $r -weight 1
            incr r
        }

        update idletasks
        update
        raise $win
    }
}

# Run comparison
generate_stage_comparison $TOP_MODULE $REPORT_DIR

# Uncomment for GUI
gui_show
