VCS = SW_VCS=2017.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 +define+
LIB = /afs/umich.edu/class/eecs598a/f21/SAED32_EDK/lib/stdcell_rvt/verilog/saed32nm.v

all:	simv
	./simv | tee program.out



TESTBENCH = sys_defs.svh test_proposed_model_w_bin.sv
SIMFILES = binarization_input.sv accumulation_new.sv proposed_model_w_bin.sv
SYNFILES = proposed_model_w_bin.vg

TCLFILES = synth/bnn.tcl

VTUBER = sys_defs.svh \
		 ISA.svh \
		 testbench/mem.sv \
		 testbench/visual_testbench_RS.sv \
		 testbench/visual_c_hooks_rob.cpp \
		 testbench/pipe_print.c \

VISFLAGS = -lncurses

proposed_model_w_bin.vg: $(SYNFILES) $(TCLFILES)
	dc_shell-t -f $(TCLFILES) | tee synth.out


#####
# Should be no need to modify after here
#####
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

vis_simv: $(SIMFILES) $(VTUBER)
	$(VCS) $(VISFLAGS) $(VTUBER) $(SIMFILES) -o vis_simv
	./vis_simv 

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out \
	syn_simv syn_simv.daidir syn_program.out \
	dve *.vpd *.vcd *.dump ucli.key 

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out DVEfiles/

