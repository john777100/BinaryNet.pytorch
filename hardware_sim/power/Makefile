pp:
	tclsh ./envset_bin.tcl
	cp ./envset_bin.tcl ./envset.tcl
	pt_shell -f pp.tset.tcl  | tee pp.log

pp_pro:	
	tclsh ./envset_pro.tcl
	cp ./envset_pro.tcl ./envset.tcl
	pt_shell -f pp.tset.tcl  | tee pp_pro.log

pp_fixed:
	tclsh ./envset_fixed.tcl
	cp ./envset_fixed.tcl ./envset.tcl
	pt_shell -f pp.tset.tcl  | tee pp_fixed.log

clean:
	rm -f *.log.*
	rm -f *.fsdb.*
	rm -f *.tset.tcl
	rm -f *.swp
	rm -f *.log
	#rm -f *.rpt
	rm -f *.fsdb
