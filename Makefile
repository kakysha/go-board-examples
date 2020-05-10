ENABLE_TRACE = 
ENABLE_VGASIM = 1

TB_DIR = testbenches
MODULES_DIR = modules
OBJ_DIR = obj_dir

#enable trace generation
ifdef ENABLE_TRACE
CFLAGS += -DTRACE
TRACE += --trace
endif

# enable VGA simulation
ifdef ENABLE_VGASIM
USER_CPP_FILES += vga/vgasim.cpp
CFLAGS += `pkg-config gtkmm-3.0 --cflags` -std=c++11 -DUSEVGASIM
LDFLAGS += `pkg-config gtkmm-3.0 --libs`
endif

sim-%: *.v $(TB_DIR)/*.cpp $(MODULES_DIR)/*.v
	cd $(TB_DIR) && \
	verilator -Wall -CFLAGS " $(CFLAGS)" -LDFLAGS " $(LDFLAGS)"  $(TRACE) --cc -I.. -I../$(MODULES_DIR) $*.v --exe $*.cpp $(USER_CPP_FILES) --relative-includes --Mdir $(OBJ_DIR)
	cd $(TB_DIR)/$(OBJ_DIR) && make -f V$*.mk
	cd $(TB_DIR)/$(OBJ_DIR) && ./V$*
ifdef ENABLE_TRACE
	gtkwave $(TB_DIR)/$(OBJ_DIR)/trace.vcd
endif

upload:
	apio verify && apio build && apio upload

.PHONY: clean
clean:
	apio clean
	-rm -fr $(TB_DIR)/$(OBJ_DIR)
