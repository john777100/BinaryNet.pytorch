VCS = SW_VCS=2017.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 +define+
LIB = /afs/umich.edu/class/eecs598a/f21/SAED32_EDK/lib/stdcell_rvt/verilog/saed32nm.v

all:	simv
	./simv | tee program.out

fixed: fixed_simv
	./fixed_simv | tee fixed_program.out


PRO_TB  = sys_defs.svh 	tb_fcl_pro.sv
PRO_SIM = fcl_pro.sv
PRO_SYN = fcl_pro.vg
PRO_TCL = synth/pro.tcl

BIN_TB  = sys_defs.svh tb_fcl_bin.sv
BIN_SIM = fcl_bin.sv
BIN_SYN = fcl_bin.vg
BIN_TCL = synth/bnn.tcl

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

fcl_fp.vg: $(FIXED_SIM) $(FIXED_TCL)
	dc_shell -f $(FIXED_TCL) | tee fixed_synth.out

fcl_bin.vg: $(BIN_SIM) $(BIN_TCL)
	dc_shell -f $(BIN_TCL) | tee bin_synth.out

fcl_pro.vg: $(PRO_SIM) $(PRO_TCL)
	dc_shell -f $(PRO_TCL) | tee pro_synth.out

#####
# Should be no need to modify after here
#####

## Binary
bin_simv:	$(BIN_SIM) $(BIN_TB)
	$(VCS) $(BIN_TB) $(BIN_SIM) -o bin_simv

bin_dve:	$(BIN_SIM) $(BIN_TB) 
	$(VCS) +memcbk $(BIN_TB) $(BIN_SIM) -o bin_dve -R -gui

bin_synth: $(BIN_SIM) $(BIN_TCL)
	dc_shell-t -f $(BIN_TCL) | tee synth.out


bin_syn_simv:	$(BIN_SYN) $(BIN_TB)
	$(VCS) $(BIN_TB) $(BIN_SYN) $(LIB) -o bin_syn_simv

bin_syn:	bin_syn_simv
	./bin_syn_simv | tee bin_syn_program.out

## Proposed
pro_simv:	$(PRO_SIM) $(PRO_TB)
	$(VCS) $(PRO_TB) $(PRO_SIM) -o pro_simv

pro_dve:	$(PRO_SIM) $(PRO_TB) 
	$(VCS) +memcbk $(PRO_TB) $(PRO_SIM) -o pro_dve -R -gui

pro_synth: $(PRO_SIM) $(PRO_TCL)
	dc_shell-t -f $(PRO_TCL) | tee synth.out


pro_syn_simv:	$(PRO_SYN) $(PRO_TB)
	$(VCS) $(PRO_TB) $(PRO_SYN) $(LIB) -o pro_syn_simv

pro_syn:	pro_syn_simv
	./pro_syn_simv | tee pro_syn_program.out

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

