TB_DIR = testbenches
MODULES_DIR = modules
OBJ_DIR = obj_dir

sim-%: *.v $(TB_DIR)/*.cpp $(MODULES_DIR)/*.v
	cd $(TB_DIR) && \
	verilator -Wall --trace --cc -I.. -I../$(MODULES_DIR) $*.v --exe $*.cpp --relative-includes --Mdir $(OBJ_DIR)
	cd $(TB_DIR)/$(OBJ_DIR) && \
	make -f V$*.mk
	cd $(TB_DIR)/$(OBJ_DIR) && ./V$*
	gtkwave $(TB_DIR)/$(OBJ_DIR)/trace.vcd

.PHONY: clean
clean:
	apio clean
	-rm -fr $(TB_DIR)/$(OBJ_DIR)
