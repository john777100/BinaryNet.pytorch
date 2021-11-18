#####################################################
#Read design data & technology
#####################################################

set CURRENT_PATH [pwd]
set TOP_DESIGN fixed_in_bin_weight

## Add libraries below:
set search_path [ list "/afs/umich.edu/class/eecs598a/f21/SAED32_EDK/lib/stdcell_rvt/db_ccs"]
set target_library "saed32rvt_tt0p85v25c.db"
set LINK_PATH [concat  "*" $target_library]

## Replace with your design names:
set SDC_PATH      "$CURRENT_PATH/.."
set STRIP_PATH    test_proposed_model_w_bin/dut

set ACTIVITY_FILE ../fixed_in_bin_weight.vcd

######## Timing Sections ########
set START_TIME 0
set	END_TIME 5000
##### replace start and end time in pp.tcl
set fp    [open pp.tcl r]
set newfp [open pp.tset.tcl w]
set map {}
lappend map {@START_TIME} $START_TIME
lappend map {@END_TIME} $END_TIME
while {[gets $fp line] >= 0} { 
	set  newline [string map $map $line] 
	puts $newfp $newline 
};
close $fp
close $newfp