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

BIN_INPUT_TCLFILES = synth/bnn_input.tcl

# FIXED_TB = sys_defs.svh testbench_idk.sv
# FIXED_SIM = idk.sv
# FIXED_SYN = fixed_in_bin_weight.vg
# FIXED_TCL = synth/fixed.tcl

FIXED_TB = sys_defs.svh tb_fcl_fp.sv
FIXED_SIM = sys_defs.svh fcl_fp.sv
FIXED_SYN = fcl_fp.vg
FIXED_TCL = synth/fixed.tcl

VTUBER = sys_defs.svh \
		 ISA.svh \
		 testbench/mem.sv \
		 testbench/visual_testbench_RS.sv \
		 testbench/visual_c_hooks_rob.cpp \
		 testbench/pipe_print.c \

VISFLAGS = -lncurses

fcl_fp.vg: $(FIXED_SIM) $(TCLFILES)
	dc_shell -f $(FIXED_TCL) | tee fixed_synth.out

idk.vg: $(FIXED_SIM) $(TCLFILES)
	dc_shell -f $(FIXED_TCL) | tee fixed_synth.out

binarization_input.vg:  $(SIMFILES) $(TCLFILES)
	dc_shell-t -f $(BIN_INPUT_TCLFILES) | tee synth.out

proposed_model_wo_bin_v2.vg: $(SIMFILES) $(TCLFILES)
	dc_shell-t -f $(TCLFILES) | tee synth.out

proposed_model_w_bin_v2.vg: $(SIMFILES) $(TCLFILES)
	dc_shell-t -f $(TCLFILES) | tee synth.out

fixed_in_bin_weight.vg: $(FIXED_SIM) $(TCLFILES)
	dc_shell-t -f $(FIXED_TCL) | tee fixed_synth.out

fixed_in_bin_weight_v2.vg: $(FIXED_SIM) $(TCLFILES)
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
	$(VCS) $(FIXED_TB) $(FIXED_SIM) -o fixed_simv

fixed_dve:	$(FIXED_SIM) $(FIXED_TB) 
	$(VCS) +memcbk $(FIXED_TB) $(FIXED_SIM) -o dve -R -gui

fixed_synth: $(FIXED_SIM) $(FIXED_TCL)
	dc_shell-t -f $(FIXED_TCL) | tee fixed_synth.out

fixed_syn_dve: $(FIXED_SYN) $(FIXED_TB)
	$(VCS) $(FIXED_TB) $(FIXED_SYN) $(LIB) -o fixed_syn_dve -R -gui

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

