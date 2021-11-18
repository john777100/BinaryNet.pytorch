VCS = SW_VCS=2017.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 +define+
LIB = /afs/umich.edu/class/eecs598a/f21/SAED32_EDK/lib/stdcell_rvt/verilog/saed32nm.v

all:	simv
	./simv | tee program.out

fixed: fixed_simv
	./fixed_simv | tee fixed_program.out


TESTBENCH = sys_defs.svh test_proposed_model_w_bin.sv
SIMFILES = binarization_input.sv accumulation_w_add_1.sv proposed_model_w_bin_v2.sv
SYNFILES = proposed_model_w_bin_v2.vg

TCLFILES = synth/bnn.tcl

FIXED_TB = sys_defs.svh test_fixed_in_bin_weight.sv
FIXED_SIM = fixed_in_bin_weight.sv
FIXED_SYN = fixed_in_bin_weight.vg
FIXED_TCL = synth/fixed.tcl

VTUBER = sys_defs.svh \
		 ISA.svh \
		 testbench/mem.sv \
		 testbench/visual_testbench_RS.sv \
		 testbench/visual_c_hooks_rob.cpp \
		 testbench/pipe_print.c \

VISFLAGS = -lncurses

proposed_model_w_bin_v2.vg: $(SYNFILES) $(TCLFILES)
	dc_shell-t -f $(TCLFILES) | tee synth.out

fixed_in_bin.vg: $(FIXED_SYN) $(TCLFILES)
	dc_shell-t -f $(FIXED_TCL) | tee fixed_synth.out

#####
# Should be no need to modify after here
#####

## Binary
simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES) -o simv

dve:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) +memcbk $(TESTBENCH) $(SIMFILES) -o dve -R -gui

.PHONY: dve

synth: $(SIMFILES) $(TCLFILES)
	dc_shell-t -f $(TCLFILES) | tee synth.out


syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv

syn:	syn_simv
	./syn_simv | tee syn_program.out

## Fixed point
fixed_simv:	$(FIXED_SIM) $(FIXED_TB)
	$(VCS) $(FIXED_TB) $(FIXED_SIM) -o simv

fixed_dve:	$(FIXED_SIM) $(FIXED_TB) 
	$(VCS) +memcbk $(FIXED_TB) $(FIXED_SIM) -o dve -R -gui

fixed_synth: $(FIXED_SIM) $(TCLFILES)
	dc_shell-t -f $(TCLFILES) | tee fixed_synth.out


fixed_syn_simv:	$(FIXED_SYN) $(FIXED_TB)
	$(VCS) $(FIXED_TB) $(FIXED_SYN) $(LIB) -o fixed_syn_simv

fixed_syn:	fixed_syn_simv
	./fixed_syn_simv | tee fixed_syn_program.out

## End of Fixed point

vis_simv: $(SIMFILES) $(VTUBER)
	$(VCS) $(VISFLAGS) $(VTUBER) $(SIMFILES) -o vis_simv
	./vis_simv 

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out \
	syn_simv syn_simv.daidir syn_program.out \
	dve *.vpd *.vcd *.dump ucli.key 

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out DVEfiles/

