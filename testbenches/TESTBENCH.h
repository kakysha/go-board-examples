#ifndef TESTBENCH_H
#define TESTBENCH_H

#ifndef CLOCK_PERIOD
	#define CLOCK_PERIOD 40 // 1000 / MHz, ns for one clock cycle
#endif

#ifdef TRACE
	#include "verilated_vcd_c.h"
#endif

template<class MODULE> class TESTBENCH {
public:
	unsigned long tickcount;
	MODULE*	m;
#ifdef TRACE
	VerilatedVcdC* tfp;
#endif

	TESTBENCH(void) {
		m = new MODULE();
		tickcount = 0l;
#ifdef TRACE
		Verilated::traceEverOn(true);
		tfp = new VerilatedVcdC();
		m->trace(tfp, 99);
		tfp->open("trace.vcd");
#endif
	}

	virtual ~TESTBENCH(void) {
#ifdef TRACE
		tfp->close();
#endif
		m->final();
		delete m;
		m = NULL;
	}

	virtual void tick(void) {
		tickcount++;
		m->eval();
		m->i_Clk = 1;
		m->eval();
#ifdef TRACE
		tfp->dump(tickcount * CLOCK_PERIOD - CLOCK_PERIOD / 2);
#endif
		m->i_Clk = 0;
		m->eval();
#ifdef TRACE
		tfp->dump(tickcount * CLOCK_PERIOD);
		tfp->flush();
#endif
	}
};

#endif